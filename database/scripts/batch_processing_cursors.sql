-- Batch Processing Cursors for Customer Loyalty Points & Rewards Automation System
-- This script creates cursors for batch processing operations

-- Connect as loyalty_owner user
-- CONN loyalty_owner/frank@localhost:1521/tue_26652_frank_loyalty_db

-- 1. Cursor to process expired points in batches
CREATE OR REPLACE PROCEDURE BATCH_EXPIRE_POINTS AS
  CURSOR expired_points_cursor IS
    SELECT point_id, customer_id, points, expiry_date
    FROM LOYALTY_POINTS
    WHERE status = 'ACTIVE'
    AND expiry_date < SYSDATE
    ORDER BY customer_id;
    
  v_processed_count NUMBER := 0;
  v_error_count NUMBER := 0;
BEGIN
  FOR expired_point_rec IN expired_points_cursor LOOP
    BEGIN
      UPDATE LOYALTY_POINTS
      SET status = 'EXPIRED'
      WHERE point_id = expired_point_rec.point_id;
      
      v_processed_count := v_processed_count + 1;
      
      -- Commit every 100 records to avoid long transactions
      IF MOD(v_processed_count, 100) = 0 THEN
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Processed ' || v_processed_count || ' expired points...');
      END IF;
      
    EXCEPTION
      WHEN OTHERS THEN
        v_error_count := v_error_count + 1;
        DBMS_OUTPUT.PUT_LINE('Error processing point ID ' || expired_point_rec.point_id || ': ' || SQLERRM);
    END;
  END LOOP;
  
  COMMIT;
  DBMS_OUTPUT.PUT_LINE('Batch expiration complete. Processed: ' || v_processed_count || ', Errors: ' || v_error_count);
  
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE('Batch expiration failed: ' || SQLERRM);
END BATCH_EXPIRE_POINTS;
/

-- 2. Cursor to generate customer activity reports
CREATE OR REPLACE PROCEDURE GENERATE_CUSTOMER_REPORT AS
  CURSOR customer_report_cursor IS
    SELECT c.customer_id, c.full_name, c.email,
           COUNT(p.purchase_id) as total_purchases,
           NVL(SUM(p.amount), 0) as total_spent,
           COUNT(lp.point_id) as total_point_entries,
           NVL(SUM(CASE WHEN lp.status = 'ACTIVE' THEN lp.points ELSE 0 END), 0) as active_points,
           COUNT(r.redemption_id) as total_redemptions
    FROM CUSTOMERS c
    LEFT JOIN PURCHASES p ON c.customer_id = p.customer_id
    LEFT JOIN LOYALTY_POINTS lp ON c.customer_id = lp.customer_id
    LEFT JOIN REDEMPTIONS r ON c.customer_id = r.customer_id
    GROUP BY c.customer_id, c.full_name, c.email
    ORDER BY total_spent DESC;
    
  v_report_count NUMBER := 0;
BEGIN
  DBMS_OUTPUT.PUT_LINE('Customer Activity Report');
  DBMS_OUTPUT.PUT_LINE('======================');
  DBMS_OUTPUT.PUT_LINE('Customer ID | Name | Email | Purchases | Total Spent | Point Entries | Active Points | Redemptions');
  DBMS_OUTPUT.PUT_LINE('------------|------|-------|-----------|-------------|---------------|---------------|-------------');
  
  FOR customer_rec IN customer_report_cursor LOOP
    v_report_count := v_report_count + 1;
    
    DBMS_OUTPUT.PUT_LINE(
      customer_rec.customer_id || ' | ' ||
      customer_rec.full_name || ' | ' ||
      customer_rec.email || ' | ' ||
      customer_rec.total_purchases || ' | ' ||
      customer_rec.total_spent || ' | ' ||
      customer_rec.total_point_entries || ' | ' ||
      customer_rec.active_points || ' | ' ||
      customer_rec.total_redemptions
    );
    
    -- Limit output for readability
    IF v_report_count >= 50 THEN
      DBMS_OUTPUT.PUT_LINE('... (report truncated for brevity)');
      EXIT;
    END IF;
  END LOOP;
  
  DBMS_OUTPUT.PUT_LINE('Report generated for ' || v_report_count || ' customers.');
  
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Report generation failed: ' || SQLERRM);
END GENERATE_CUSTOMER_REPORT;
/

-- 3. Cursor to process bulk promotional bonuses
CREATE OR REPLACE PROCEDURE BULK_PROMOTIONAL_BONUS (
  p_bonus_points IN NUMBER,
  p_promotion_name IN VARCHAR2
) AS
  CURSOR active_customers_cursor IS
    SELECT customer_id, full_name
    FROM CUSTOMERS
    WHERE customer_id IN (
      SELECT DISTINCT customer_id 
      FROM PURCHASES 
      WHERE purchase_date >= ADD_MONTHS(SYSDATE, -6) -- Active in last 6 months
    )
    ORDER BY customer_id;
    
  v_processed_count NUMBER := 0;
  v_error_count NUMBER := 0;
  v_points_id NUMBER;
BEGIN
  DBMS_OUTPUT.PUT_LINE('Starting bulk promotional bonus for: ' || p_promotion_name);
  
  FOR customer_rec IN active_customers_cursor LOOP
    BEGIN
      -- Generate new point ID
      SELECT LOYALTY_POINTS_SEQ.NEXTVAL INTO v_points_id FROM DUAL;
      
      -- Insert promotional bonus points record
      INSERT INTO LOYALTY_POINTS (
        point_id,
        customer_id,
        points,
        earned_date,
        expiry_date,
        status,
        purchase_id
      ) VALUES (
        v_points_id,
        customer_rec.customer_id,
        p_bonus_points,
        SYSDATE,
        ADD_MONTHS(SYSDATE, 3), -- Bonus points expire after 3 months
        'ACTIVE',
        NULL
      );
      
      v_processed_count := v_processed_count + 1;
      
      -- Commit every 50 records
      IF MOD(v_processed_count, 50) = 0 THEN
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Processed ' || v_processed_count || ' customers for promotional bonus...');
      END IF;
      
    EXCEPTION
      WHEN OTHERS THEN
        v_error_count := v_error_count + 1;
        DBMS_OUTPUT.PUT_LINE('Error processing customer ID ' || customer_rec.customer_id || ': ' || SQLERRM);
    END;
  END LOOP;
  
  COMMIT;
  DBMS_OUTPUT.PUT_LINE('Bulk promotional bonus complete.');
  DBMS_OUTPUT.PUT_LINE('Processed: ' || v_processed_count || ' customers');
  DBMS_OUTPUT.PUT_LINE('Errors: ' || v_error_count);
  
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE('Bulk promotional bonus failed: ' || SQLERRM);
END BULK_PROMOTIONAL_BONUS;
/

-- 4. Explicit cursor example with bulk operations
CREATE OR REPLACE PROCEDURE BULK_UPDATE_INACTIVE_CUSTOMERS AS
  CURSOR inactive_customers_cursor IS
    SELECT customer_id, full_name
    FROM CUSTOMERS c
    WHERE NOT EXISTS (
      SELECT 1 
      FROM PURCHASES p 
      WHERE p.customer_id = c.customer_id 
      AND p.purchase_date >= ADD_MONTHS(SYSDATE, -12) -- No purchases in last year
    );
    
  TYPE customer_id_array IS TABLE OF NUMBER;
  TYPE customer_name_array IS TABLE OF VARCHAR2(100);
  
  v_customer_ids customer_id_array;
  v_customer_names customer_name_array;
  
  v_processed_count NUMBER := 0;
BEGIN
  OPEN inactive_customers_cursor;
  
  LOOP
    FETCH inactive_customers_cursor 
    BULK COLLECT INTO v_customer_ids, v_customer_names
    LIMIT 100; -- Process in batches of 100
    
    -- Exit loop if no more records
    EXIT WHEN v_customer_ids.COUNT = 0;
    
    -- Process the batch
    FOR i IN 1 .. v_customer_ids.COUNT LOOP
      DBMS_OUTPUT.PUT_LINE('Inactive customer: ' || v_customer_names(i) || ' (ID: ' || v_customer_ids(i) || ')');
      v_processed_count := v_processed_count + 1;
    END LOOP;
    
    -- Reset arrays for next batch
    v_customer_ids.DELETE;
    v_customer_names.DELETE;
  END LOOP;
  
  CLOSE inactive_customers_cursor;
  
  DBMS_OUTPUT.PUT_LINE('Found ' || v_processed_count || ' inactive customers.');
  
EXCEPTION
  WHEN OTHERS THEN
    IF inactive_customers_cursor%ISOPEN THEN
      CLOSE inactive_customers_cursor;
    END IF;
    DBMS_OUTPUT.PUT_LINE('Error in bulk update: ' || SQLERRM);
END BULK_UPDATE_INACTIVE_CUSTOMERS;
/

-- Display procedure information
SELECT object_name, object_type, status 
FROM user_objects 
WHERE object_type = 'PROCEDURE' 
AND object_name IN ('BATCH_EXPIRE_POINTS', 'GENERATE_CUSTOMER_REPORT', 'BULK_PROMOTIONAL_BONUS', 'BULK_UPDATE_INACTIVE_CUSTOMERS')
ORDER BY object_name;