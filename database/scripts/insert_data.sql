-- Sample Data Insertion Script for Customer Loyalty Points & Rewards Automation System
-- This script inserts 100-500+ realistic rows per main table to meet project requirements

-- Connect as loyalty_owner user
-- CONN loyalty_owner/frank@localhost:1521/tue_26652_frank_loyalty_db

-- Insert 200 sample customers with diverse demographics
BEGIN
  FOR i IN 1..200 LOOP
    INSERT INTO CUSTOMERS (customer_id, full_name, phone, email) 
    VALUES (CUSTOMERS_SEQ.NEXTVAL, 
            'Customer' || i || ' Name', 
            '+1' || LPAD(TRUNC(DBMS_RANDOM.VALUE(1000000000, 9999999999)), 10, '0'), 
            'customer' || i || '@email' || MOD(i, 10) || '.com');
  END LOOP;
  COMMIT;
END;
/

-- Insert additional customers with specific names for easier tracking
INSERT INTO CUSTOMERS (customer_id, full_name, phone, email) VALUES (CUSTOMERS_SEQ.NEXTVAL, 'John Smith', '+1234567890', 'john.smith@email.com');
INSERT INTO CUSTOMERS (customer_id, full_name, phone, email) VALUES (CUSTOMERS_SEQ.NEXTVAL, 'Sarah Johnson', '+1234567891', 'sarah.johnson@email.com');
INSERT INTO CUSTOMERS (customer_id, full_name, phone, email) VALUES (CUSTOMERS_SEQ.NEXTVAL, 'Michael Brown', '+1234567892', 'michael.brown@email.com');
INSERT INTO CUSTOMERS (customer_id, full_name, phone, email) VALUES (CUSTOMERS_SEQ.NEXTVAL, 'Emily Davis', '+1234567893', 'emily.davis@email.com');
INSERT INTO CUSTOMERS (customer_id, full_name, phone, email) VALUES (CUSTOMERS_SEQ.NEXTVAL, 'Robert Wilson', '+1234567894', 'robert.wilson@email.com');
INSERT INTO CUSTOMERS (customer_id, full_name, phone, email) VALUES (CUSTOMERS_SEQ.NEXTVAL, 'Jennifer Lee', '+1234567895', 'jennifer.lee@email.com');
INSERT INTO CUSTOMERS (customer_id, full_name, phone, email) VALUES (CUSTOMERS_SEQ.NEXTVAL, 'David Miller', '+1234567896', 'david.miller@email.com');
INSERT INTO CUSTOMERS (customer_id, full_name, phone, email) VALUES (CUSTOMERS_SEQ.NEXTVAL, 'Lisa Taylor', '+1234567897', 'lisa.taylor@email.com');
INSERT INTO CUSTOMERS (customer_id, full_name, phone, email) VALUES (CUSTOMERS_SEQ.NEXTVAL, 'James Anderson', '+1234567898', 'james.anderson@email.com');
INSERT INTO CUSTOMERS (customer_id, full_name, phone, email) VALUES (CUSTOMERS_SEQ.NEXTVAL, 'Patricia Thomas', '+1234567899', 'patricia.thomas@email.com');

-- Insert 150 sample rewards with various point requirements
BEGIN
  FOR i IN 1..50 LOOP
    INSERT INTO REWARDS (reward_id, reward_name, points_required, availability_status) 
    VALUES (REWARDS_SEQ.NEXTVAL, 
            'Free Coffee #' || i, 
            100, 
            CASE WHEN MOD(i, 10) = 0 THEN 'UNAVAILABLE' ELSE 'AVAILABLE' END);
  END LOOP;
  
  FOR i IN 1..30 LOOP
    INSERT INTO REWARDS (reward_id, reward_name, points_required, availability_status) 
    VALUES (REWARDS_SEQ.NEXTVAL, 
            '$10 Gift Card #' || i, 
            500, 
            CASE WHEN MOD(i, 8) = 0 THEN 'UNAVAILABLE' ELSE 'AVAILABLE' END);
  END LOOP;
  
  FOR i IN 1..20 LOOP
    INSERT INTO REWARDS (reward_id, reward_name, points_required, availability_status) 
    VALUES (REWARDS_SEQ.NEXTVAL, 
            'Movie Tickets #' || i, 
            1000, 
            CASE WHEN MOD(i, 5) = 0 THEN 'UNAVAILABLE' ELSE 'AVAILABLE' END);
  END LOOP;
  
  FOR i IN 1..20 LOOP
    INSERT INTO REWARDS (reward_id, reward_name, points_required, availability_status) 
    VALUES (REWARDS_SEQ.NEXTVAL, 
            '$25 Gift Card #' || i, 
            1200, 
            CASE WHEN MOD(i, 6) = 0 THEN 'UNAVAILABLE' ELSE 'AVAILABLE' END);
  END LOOP;
  
  FOR i IN 1..15 LOOP
    INSERT INTO REWARDS (reward_id, reward_name, points_required, availability_status) 
    VALUES (REWARDS_SEQ.NEXTVAL, 
            'Free Meal #' || i, 
            800, 
            CASE WHEN MOD(i, 4) = 0 THEN 'UNAVAILABLE' ELSE 'AVAILABLE' END);
  END LOOP;
  
  FOR i IN 1..10 LOOP
    INSERT INTO REWARDS (reward_id, reward_name, points_required, availability_status) 
    VALUES (REWARDS_SEQ.NEXTVAL, 
            '$50 Gift Card #' || i, 
            2500, 
            CASE WHEN MOD(i, 3) = 0 THEN 'UNAVAILABLE' ELSE 'AVAILABLE' END);
  END LOOP;
  
  FOR i IN 1..3 LOOP
    INSERT INTO REWARDS (reward_id, reward_name, points_required, availability_status) 
    VALUES (REWARDS_SEQ.NEXTVAL, 
            'Weekend Getaway #' || i, 
            10000, 
            CASE WHEN MOD(i, 2) = 0 THEN 'UNAVAILABLE' ELSE 'AVAILABLE' END);
  END LOOP;
  
  FOR i IN 1..2 LOOP
    INSERT INTO REWARDS (reward_id, reward_name, points_required, availability_status) 
    VALUES (REWARDS_SEQ.NEXTVAL, 
            'Smartphone #' || i, 
            15000, 
            'UNAVAILABLE');
  END LOOP;
  COMMIT;
END;
/

-- Insert 300 sample purchases across customers with realistic dates and amounts
BEGIN
  FOR i IN 1..300 LOOP
    INSERT INTO PURCHASES (purchase_id, customer_id, purchase_date, amount, store_location) 
    VALUES (PURCHASES_SEQ.NEXTVAL, 
            TRUNC(DBMS_RANDOM.VALUE(1, 210)), -- Random customer ID between 1-210
            TO_DATE('2024-' || LPAD(TRUNC(DBMS_RANDOM.VALUE(1, 13)), 2, '0') || '-' || 
                   LPAD(TRUNC(DBMS_RANDOM.VALUE(1, 29)), 2, '0'), 'YYYY-MM-DD'),
            ROUND(DBMS_RANDOM.VALUE(10, 500), 2), -- Random amount between $10-$500
            CASE MOD(i, 3)
              WHEN 0 THEN 'Downtown Store'
              WHEN 1 THEN 'Mall Location'
              ELSE 'Airport Location'
            END);
  END LOOP;
  COMMIT;
END;
/

-- Insert sample purchases for specific customers (John Smith, Sarah Johnson, etc.)
INSERT INTO PURCHASES (purchase_id, customer_id, purchase_date, amount, store_location) VALUES (PURCHASES_SEQ.NEXTVAL, 201, TO_DATE('2025-01-15', 'YYYY-MM-DD'), 45.50, 'Downtown Store');
INSERT INTO PURCHASES (purchase_id, customer_id, purchase_date, amount, store_location) VALUES (PURCHASES_SEQ.NEXTVAL, 201, TO_DATE('2025-02-03', 'YYYY-MM-DD'), 120.75, 'Mall Location');
INSERT INTO PURCHASES (purchase_id, customer_id, purchase_date, amount, store_location) VALUES (PURCHASES_SEQ.NEXTVAL, 201, TO_DATE('2025-02-20', 'YYYY-MM-DD'), 89.99, 'Downtown Store');
INSERT INTO PURCHASES (purchase_id, customer_id, purchase_date, amount, store_location) VALUES (PURCHASES_SEQ.NEXTVAL, 201, TO_DATE('2025-03-10', 'YYYY-MM-DD'), 210.25, 'Airport Location');

INSERT INTO PURCHASES (purchase_id, customer_id, purchase_date, amount, store_location) VALUES (PURCHASES_SEQ.NEXTVAL, 202, TO_DATE('2025-01-22', 'YYYY-MM-DD'), 67.30, 'Mall Location');
INSERT INTO PURCHASES (purchase_id, customer_id, purchase_date, amount, store_location) VALUES (PURCHASES_SEQ.NEXTVAL, 202, TO_DATE('2025-02-14', 'YYYY-MM-DD'), 150.00, 'Downtown Store');
INSERT INTO PURCHASES (purchase_id, customer_id, purchase_date, amount, store_location) VALUES (PURCHASES_SEQ.NEXTVAL, 202, TO_DATE('2025-03-05', 'YYYY-MM-DD'), 95.45, 'Mall Location');

INSERT INTO PURCHASES (purchase_id, customer_id, purchase_date, amount, store_location) VALUES (PURCHASES_SEQ.NEXTVAL, 203, TO_DATE('2025-01-30', 'YYYY-MM-DD'), 200.00, 'Airport Location');
INSERT INTO PURCHASES (purchase_id, customer_id, purchase_date, amount, store_location) VALUES (PURCHASES_SEQ.NEXTVAL, 203, TO_DATE('2025-02-18', 'YYYY-MM-DD'), 75.25, 'Downtown Store');

INSERT INTO PURCHASES (purchase_id, customer_id, purchase_date, amount, store_location) VALUES (PURCHASES_SEQ.NEXTVAL, 204, TO_DATE('2025-02-05', 'YYYY-MM-DD'), 55.80, 'Mall Location');
INSERT INTO PURCHASES (purchase_id, customer_id, purchase_date, amount, store_location) VALUES (PURCHASES_SEQ.NEXTVAL, 205, TO_DATE('2025-01-28', 'YYYY-MM-DD'), 180.60, 'Downtown Store');
INSERT INTO PURCHASES (purchase_id, customer_id, purchase_date, amount, store_location) VALUES (PURCHASES_SEQ.NEXTVAL, 206, TO_DATE('2025-03-12', 'YYYY-MM-DD'), 92.40, 'Airport Location');
INSERT INTO PURCHASES (purchase_id, customer_id, purchase_date, amount, store_location) VALUES (PURCHASES_SEQ.NEXTVAL, 207, TO_DATE('2025-02-25', 'YYYY-MM-DD'), 135.70, 'Mall Location');
INSERT INTO PURCHASES (purchase_id, customer_id, purchase_date, amount, store_location) VALUES (PURCHASES_SEQ.NEXTVAL, 208, TO_DATE('2025-03-08', 'YYYY-MM-DD'), 68.90, 'Downtown Store');
INSERT INTO PURCHASES (purchase_id, customer_id, purchase_date, amount, store_location) VALUES (PURCHASES_SEQ.NEXTVAL, 209, TO_DATE('2025-01-20', 'YYYY-MM-DD'), 210.30, 'Airport Location');
INSERT INTO PURCHASES (purchase_id, customer_id, purchase_date, amount, store_location) VALUES (PURCHASES_SEQ.NEXTVAL, 210, TO_DATE('2025-03-15', 'YYYY-MM-DD'), 175.55, 'Mall Location');

-- Insert 400 sample loyalty points with various statuses and realistic distributions
BEGIN
  FOR i IN 1..400 LOOP
    INSERT INTO LOYALTY_POINTS (point_id, customer_id, points, earned_date, expiry_date, status, purchase_id) 
    VALUES (LOYALTY_POINTS_SEQ.NEXTVAL, 
            TRUNC(DBMS_RANDOM.VALUE(1, 210)), -- Random customer ID
            TRUNC(DBMS_RANDOM.VALUE(10, 500)), -- Random points between 10-500
            TO_DATE('2024-' || LPAD(TRUNC(DBMS_RANDOM.VALUE(1, 13)), 2, '0') || '-' || 
                   LPAD(TRUNC(DBMS_RANDOM.VALUE(1, 29)), 2, '0'), 'YYYY-MM-DD'),
            TO_DATE('2025-' || LPAD(TRUNC(DBMS_RANDOM.VALUE(1, 13)), 2, '0') || '-' || 
                   LPAD(TRUNC(DBMS_RANDOM.VALUE(1, 29)), 2, '0'), 'YYYY-MM-DD'),
            CASE MOD(i, 20)
              WHEN 0 THEN 'EXPIRED'
              WHEN 1 THEN 'REDEEMED'
              ELSE 'ACTIVE'
            END,
            CASE WHEN MOD(i, 5) = 0 THEN NULL ELSE TRUNC(DBMS_RANDOM.VALUE(1, 310)) END); -- Some without purchase_id
  END LOOP;
  COMMIT;
END;
/

-- Insert sample loyalty points for specific customers with known purchase associations
-- Assuming 1 point per $1 spent
INSERT INTO LOYALTY_POINTS (point_id, customer_id, points, earned_date, expiry_date, status, purchase_id) 
VALUES (LOYALTY_POINTS_SEQ.NEXTVAL, 201, 46, TO_DATE('2025-01-15', 'YYYY-MM-DD'), TO_DATE('2026-01-15', 'YYYY-MM-DD'), 'ACTIVE', 301);

INSERT INTO LOYALTY_POINTS (point_id, customer_id, points, earned_date, expiry_date, status, purchase_id) 
VALUES (LOYALTY_POINTS_SEQ.NEXTVAL, 201, 121, TO_DATE('2025-02-03', 'YYYY-MM-DD'), TO_DATE('2026-02-03', 'YYYY-MM-DD'), 'ACTIVE', 302);

INSERT INTO LOYALTY_POINTS (point_id, customer_id, points, earned_date, expiry_date, status, purchase_id) 
VALUES (LOYALTY_POINTS_SEQ.NEXTVAL, 201, 90, TO_DATE('2025-02-20', 'YYYY-MM-DD'), TO_DATE('2026-02-20', 'YYYY-MM-DD'), 'ACTIVE', 303);

INSERT INTO LOYALTY_POINTS (point_id, customer_id, points, earned_date, expiry_date, status, purchase_id) 
VALUES (LOYALTY_POINTS_SEQ.NEXTVAL, 201, 210, TO_DATE('2025-03-10', 'YYYY-MM-DD'), TO_DATE('2026-03-10', 'YYYY-MM-DD'), 'ACTIVE', 304);

-- Insert sample loyalty points for customer 2 (Sarah Johnson)
INSERT INTO LOYALTY_POINTS (point_id, customer_id, points, earned_date, expiry_date, status, purchase_id) 
VALUES (LOYALTY_POINTS_SEQ.NEXTVAL, 202, 67, TO_DATE('2025-01-22', 'YYYY-MM-DD'), TO_DATE('2026-01-22', 'YYYY-MM-DD'), 'ACTIVE', 305);

INSERT INTO LOYALTY_POINTS (point_id, customer_id, points, earned_date, expiry_date, status, purchase_id) 
VALUES (LOYALTY_POINTS_SEQ.NEXTVAL, 202, 150, TO_DATE('2025-02-14', 'YYYY-MM-DD'), TO_DATE('2026-02-14', 'YYYY-MM-DD'), 'ACTIVE', 306);

INSERT INTO LOYALTY_POINTS (point_id, customer_id, points, earned_date, expiry_date, status, purchase_id) 
VALUES (LOYALTY_POINTS_SEQ.NEXTVAL, 202, 95, TO_DATE('2025-03-05', 'YYYY-MM-DD'), TO_DATE('2026-03-05', 'YYYY-MM-DD'), 'ACTIVE', 307);

-- Insert sample loyalty points for other customers
INSERT INTO LOYALTY_POINTS (point_id, customer_id, points, earned_date, expiry_date, status, purchase_id) 
VALUES (LOYALTY_POINTS_SEQ.NEXTVAL, 203, 200, TO_DATE('2025-01-30', 'YYYY-MM-DD'), TO_DATE('2026-01-30', 'YYYY-MM-DD'), 'ACTIVE', 308);

INSERT INTO LOYALTY_POINTS (point_id, customer_id, points, earned_date, expiry_date, status, purchase_id) 
VALUES (LOYALTY_POINTS_SEQ.NEXTVAL, 203, 75, TO_DATE('2025-02-18', 'YYYY-MM-DD'), TO_DATE('2026-02-18', 'YYYY-MM-DD'), 'ACTIVE', 309);

INSERT INTO LOYALTY_POINTS (point_id, customer_id, points, earned_date, expiry_date, status, purchase_id) 
VALUES (LOYALTY_POINTS_SEQ.NEXTVAL, 204, 56, TO_DATE('2025-02-05', 'YYYY-MM-DD'), TO_DATE('2026-02-05', 'YYYY-MM-DD'), 'ACTIVE', 310);

INSERT INTO LOYALTY_POINTS (point_id, customer_id, points, earned_date, expiry_date, status, purchase_id) 
VALUES (LOYALTY_POINTS_SEQ.NEXTVAL, 205, 181, TO_DATE('2025-01-28', 'YYYY-MM-DD'), TO_DATE('2026-01-28', 'YYYY-MM-DD'), 'ACTIVE', 311);

-- Insert some expired points for demonstration
INSERT INTO LOYALTY_POINTS (point_id, customer_id, points, earned_date, expiry_date, status, purchase_id) 
VALUES (LOYALTY_POINTS_SEQ.NEXTVAL, 201, 50, TO_DATE('2023-01-15', 'YYYY-MM-DD'), TO_DATE('2024-01-15', 'YYYY-MM-DD'), 'EXPIRED', NULL);

-- Insert some redeemed points for demonstration
INSERT INTO LOYALTY_POINTS (point_id, customer_id, points, earned_date, expiry_date, status, purchase_id) 
VALUES (LOYALTY_POINTS_SEQ.NEXTVAL, 202, 100, TO_DATE('2024-12-01', 'YYYY-MM-DD'), TO_DATE('2025-12-01', 'YYYY-MM-DD'), 'REDEEMED', NULL);

-- Insert 150 sample redemptions with realistic distributions
BEGIN
  FOR i IN 1..150 LOOP
    INSERT INTO REDEMPTIONS (redemption_id, customer_id, reward_id, redemption_date, points_deducted) 
    VALUES (REDEMPTIONS_SEQ.NEXTVAL, 
            TRUNC(DBMS_RANDOM.VALUE(1, 210)), -- Random customer ID
            TRUNC(DBMS_RANDOM.VALUE(1, 150)), -- Random reward ID
            TO_DATE('2025-' || LPAD(TRUNC(DBMS_RANDOM.VALUE(1, 4)), 2, '0') || '-' || 
                   LPAD(TRUNC(DBMS_RANDOM.VALUE(1, 29)), 2, '0'), 'YYYY-MM-DD'),
            CASE MOD(i, 4)
              WHEN 0 THEN 100
              WHEN 1 THEN 500
              WHEN 2 THEN 800
              ELSE 1200
            END);
  END LOOP;
  COMMIT;
END;
/

-- Insert sample redemptions for specific customers
INSERT INTO REDEMPTIONS (redemption_id, customer_id, reward_id, redemption_date, points_deducted) 
VALUES (REDEMPTIONS_SEQ.NEXTVAL, 202, 1, TO_DATE('2025-03-01', 'YYYY-MM-DD'), 100);

INSERT INTO REDEMPTIONS (redemption_id, customer_id, reward_id, redemption_date, points_deducted) 
VALUES (REDEMPTIONS_SEQ.NEXTVAL, 201, 2, TO_DATE('2025-02-28', 'YYYY-MM-DD'), 500);

-- Insert some redemptions with NULL values to test edge cases
INSERT INTO REDEMPTIONS (redemption_id, customer_id, reward_id, redemption_date, points_deducted) 
VALUES (REDEMPTIONS_SEQ.NEXTVAL, 50, 10, TO_DATE('2025-01-15', 'YYYY-MM-DD'), 100);

-- Commit all changes
COMMIT;

-- Display summary of inserted data
SELECT 'CUSTOMERS' AS TABLE_NAME, COUNT(*) AS RECORD_COUNT FROM CUSTOMERS
UNION ALL
SELECT 'PURCHASES' AS TABLE_NAME, COUNT(*) AS RECORD_COUNT FROM PURCHASES
UNION ALL
SELECT 'LOYALTY_POINTS' AS TABLE_NAME, COUNT(*) AS RECORD_COUNT FROM LOYALTY_POINTS
UNION ALL
SELECT 'REWARDS' AS TABLE_NAME, COUNT(*) AS RECORD_COUNT FROM REWARDS
UNION ALL
SELECT 'REDEMPTIONS' AS TABLE_NAME, COUNT(*) AS RECORD_COUNT FROM REDEMPTIONS
ORDER BY TABLE_NAME;

-- Display sample data from each table
SELECT 'CUSTOMERS' AS TABLE_NAME, customer_id, full_name, phone FROM CUSTOMERS WHERE ROWNUM <= 5
UNION ALL
SELECT 'PURCHASES' AS TABLE_NAME, purchase_id, customer_id, amount FROM PURCHASES WHERE ROWNUM <= 5
UNION ALL
SELECT 'LOYALTY_POINTS' AS TABLE_NAME, point_id, customer_id, points FROM LOYALTY_POINTS WHERE ROWNUM <= 5
UNION ALL
SELECT 'REWARDS' AS TABLE_NAME, reward_id, reward_name, points_required FROM REWARDS WHERE ROWNUM <= 5
UNION ALL
SELECT 'REDEMPTIONS' AS TABLE_NAME, redemption_id, customer_id, reward_id FROM REDEMPTIONS WHERE ROWNUM <= 5;