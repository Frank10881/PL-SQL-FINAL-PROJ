-- Exception Handling for Customer Loyalty Points & Rewards Automation System
-- This script demonstrates comprehensive exception handling in PL/SQL

-- Connect as loyalty_owner user
-- CONN loyalty_owner/frank@localhost:1521/tue_26652_frank_loyalty_db

-- Create error log table
BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE ERROR_LOG CASCADE CONSTRAINTS';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE != -942 THEN
      RAISE;
    END IF;
END;
/

CREATE TABLE ERROR_LOG (
  error_id NUMBER GENERATED ALWAYS AS IDENTITY,
  error_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  error_code NUMBER,
  error_message VARCHAR2(4000),
  procedure_name VARCHAR2(100),
  customer_id NUMBER,
  additional_info VARCHAR2(4000)
);

-- Create sequence for error log (if needed for older Oracle versions)
BEGIN
  EXECUTE IMMEDIATE 'CREATE SEQUENCE ERROR_LOG_SEQ START WITH 1 INCREMENT BY 1';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE != -955 THEN
      RAISE;
    END IF;
END;
/

-- 1. Enhanced procedure with comprehensive exception handling
CREATE OR REPLACE PROCEDURE ADD_LOYALTY_POINTS_WITH_ERROR_HANDLING (
  p_customer_id IN NUMBER,
  p_purchase_id IN NUMBER,
  p_points IN NUMBER,
  p_result_message OUT VARCHAR2
) AS
  v_customer_exists NUMBER;
  v_purchase_exists NUMBER;
  v_points_id NUMBER;
  
  -- Custom exceptions
  customer_not_found EXCEPTION;
  purchase_not_found EXCEPTION;
  invalid_points_value EXCEPTION;
  duplicate_entry EXCEPTION;
  
  -- Standard Oracle exceptions
  pragma exception_init(duplicate_entry, -1);
BEGIN
  -- Initialize result message
  p_result_message := 'Processing...';
  
  -- Validate customer exists
  BEGIN
    SELECT COUNT(*) INTO v_customer_exists 
    FROM CUSTOMERS 
    WHERE customer_id = p_customer_id;
    
    IF v_customer_exists = 0 THEN
      RAISE customer_not_found;
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE customer_not_found;
    WHEN TOO_MANY_ROWS THEN
      RAISE_APPLICATION_ERROR(-20001, 'Multiple customers found with same ID');
  END;
  
  -- Validate purchase exists
  BEGIN
    SELECT COUNT(*) INTO v_purchase_exists 
    FROM PURCHASES 
    WHERE purchase_id = p_purchase_id;
    
    IF v_purchase_exists = 0 THEN
      RAISE purchase_not_found;
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE purchase_not_found;
  END;
  
  -- Validate points value
  IF p_points IS NULL OR p_points <= 0 THEN
    RAISE invalid_points_value;
  END IF;
  
  -- Generate new point ID
  SELECT LOYALTY_POINTS_SEQ.NEXTVAL INTO v_points_id FROM DUAL;
  
  -- Insert loyalty points record
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
    p_customer_id,
    p_points,
    SYSDATE,
    ADD_MONTHS(SYSDATE, 12),
    'ACTIVE',
    p_purchase_id
  );
  
  COMMIT;
  p_result_message := 'Success: ' || p_points || ' points added for customer ID ' || p_customer_id;
  
EXCEPTION
  WHEN customer_not_found THEN
    ROLLBACK;
    p_result_message := 'Error: Customer ID ' || p_customer_id || ' does not exist';
    INSERT INTO ERROR_LOG (error_code, error_message, procedure_name, customer_id)
    VALUES (-20002, 'Customer not found', 'ADD_LOYALTY_POINTS_WITH_ERROR_HANDLING', p_customer_id);
    COMMIT;
    
  WHEN purchase_not_found THEN
    ROLLBACK;
    p_result_message := 'Error: Purchase ID ' || p_purchase_id || ' does not exist';
    INSERT INTO ERROR_LOG (error_code, error_message, procedure_name, customer_id)
    VALUES (-20003, 'Purchase not found', 'ADD_LOYALTY_POINTS_WITH_ERROR_HANDLING', p_customer_id);
    COMMIT;
    
  WHEN invalid_points_value THEN
    ROLLBACK;
    p_result_message := 'Error: Points must be greater than zero';
    INSERT INTO ERROR_LOG (error_code, error_message, procedure_name, customer_id)
    VALUES (-20004, 'Invalid points value', 'ADD_LOYALTY_POINTS_WITH_ERROR_HANDLING', p_customer_id);
    COMMIT;
    
  WHEN duplicate_entry THEN
    ROLLBACK;
    p_result_message := 'Error: Duplicate entry detected';
    INSERT INTO ERROR_LOG (error_code, error_message, procedure_name, customer_id)
    VALUES (-1, 'Duplicate entry', 'ADD_LOYALTY_POINTS_WITH_ERROR_HANDLING', p_customer_id);
    COMMIT;
    
  WHEN VALUE_ERROR THEN
    ROLLBACK;
    p_result_message := 'Error: Numeric overflow or invalid data type';
    INSERT INTO ERROR_LOG (error_code, error_message, procedure_name, customer_id)
    VALUES (-6502, 'Value error', 'ADD_LOYALTY_POINTS_WITH_ERROR_HANDLING', p_customer_id);
    COMMIT;
    
  WHEN STORAGE_ERROR THEN
    ROLLBACK;
    p_result_message := 'Error: Insufficient storage space';
    INSERT INTO ERROR_LOG (error_code, error_message, procedure_name, customer_id)
    VALUES (-6500, 'Storage error', 'ADD_LOYALTY_POINTS_WITH_ERROR_HANDLING', p_customer_id);
    COMMIT;
    
  WHEN PROGRAM_ERROR THEN
    ROLLBACK;
    p_result_message := 'Error: Internal PL/SQL error';
    INSERT INTO ERROR_LOG (error_code, error_message, procedure_name, customer_id)
    VALUES (-6501, 'Program error', 'ADD_LOYALTY_POINTS_WITH_ERROR_HANDLING', p_customer_id);
    COMMIT;
    
  WHEN DUP_VAL_ON_INDEX THEN
    ROLLBACK;
    p_result_message := 'Error: Duplicate value violates unique constraint';
    INSERT INTO ERROR_LOG (error_code, error_message, procedure_name, customer_id)
    VALUES (-1, 'Duplicate value on index', 'ADD_LOYALTY_POINTS_WITH_ERROR_HANDLING', p_customer_id);
    COMMIT;
    
  WHEN INVALID_NUMBER THEN
    ROLLBACK;
    p_result_message := 'Error: Invalid number format';
    INSERT INTO ERROR_LOG (error_code, error_message, procedure_name, customer_id)
    VALUES (-1722, 'Invalid number', 'ADD_LOYALTY_POINTS_WITH_ERROR_HANDLING', p_customer_id);
    COMMIT;
    
  WHEN NO_DATA_FOUND THEN
    ROLLBACK;
    p_result_message := 'Error: No data found for the given parameters';
    INSERT INTO ERROR_LOG (error_code, error_message, procedure_name, customer_id)
    VALUES (100, 'No data found', 'ADD_LOYALTY_POINTS_WITH_ERROR_HANDLING', p_customer_id);
    COMMIT;
    
  WHEN TOO_MANY_ROWS THEN
    ROLLBACK;
    p_result_message := 'Error: Query returned more than one row';
    INSERT INTO ERROR_LOG (error_code, error_message, procedure_name, customer_id)
    VALUES (-1422, 'Too many rows', 'ADD_LOYALTY_POINTS_WITH_ERROR_HANDLING', p_customer_id);
    COMMIT;
    
  WHEN OTHERS THEN
    ROLLBACK;
    p_result_message := 'Unexpected error: ' || SQLERRM || ' (Error Code: ' || SQLCODE || ')';
    INSERT INTO ERROR_LOG (error_code, error_message, procedure_name, customer_id, additional_info)
    VALUES (SQLCODE, SQLERRM, 'ADD_LOYALTY_POINTS_WITH_ERROR_HANDLING', p_customer_id, 'Unexpected error');
    COMMIT;
END ADD_LOYALTY_POINTS_WITH_ERROR_HANDLING;
/

-- 2. Function with exception handling
CREATE OR REPLACE FUNCTION GET_CUSTOMER_POINTS_SAFE (
  p_customer_id IN NUMBER
) RETURN NUMBER AS
  v_total_points NUMBER;
BEGIN
  SELECT NVL(SUM(points), 0) INTO v_total_points
  FROM LOYALTY_POINTS
  WHERE customer_id = p_customer_id 
  AND status = 'ACTIVE';
  
  RETURN v_total_points;
  
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN 0;
  WHEN TOO_MANY_ROWS THEN
    -- This shouldn't happen with SUM, but just in case
    RETURN -1;
  WHEN INVALID_NUMBER THEN
    RETURN -1;
  WHEN OTHERS THEN
    -- Log the error and return error indicator
    INSERT INTO ERROR_LOG (error_code, error_message, procedure_name, customer_id)
    VALUES (SQLCODE, SQLERRM, 'GET_CUSTOMER_POINTS_SAFE', p_customer_id);
    COMMIT;
    RETURN -1;
END GET_CUSTOMER_POINTS_SAFE;
/

-- 3. Procedure to display error log
CREATE OR REPLACE PROCEDURE DISPLAY_ERROR_LOG (
  p_days_back IN NUMBER DEFAULT 7
) AS
  CURSOR error_log_cursor IS
    SELECT error_id, error_timestamp, error_code, error_message, procedure_name, customer_id
    FROM ERROR_LOG
    WHERE error_timestamp >= SYSDATE - p_days_back
    ORDER BY error_timestamp DESC;
    
  v_error_count NUMBER := 0;
BEGIN
  DBMS_OUTPUT.PUT_LINE('=== Error Log Report (Last ' || p_days_back || ' days) ===');
  DBMS_OUTPUT.PUT_LINE('ID | Timestamp | Code | Message | Procedure | Customer ID');
  DBMS_OUTPUT.PUT_LINE('---|-----------|------|---------|-----------|------------');
  
  FOR error_rec IN error_log_cursor LOOP
    v_error_count := v_error_count + 1;
    DBMS_OUTPUT.PUT_LINE(
      error_rec.error_id || ' | ' ||
      TO_CHAR(error_rec.error_timestamp, 'YYYY-MM-DD HH24:MI:SS') || ' | ' ||
      error_rec.error_code || ' | ' ||
      SUBSTR(error_rec.error_message, 1, 30) || ' | ' ||
      error_rec.procedure_name || ' | ' ||
      NVL(TO_CHAR(error_rec.customer_id), 'N/A')
    );
  END LOOP;
  
  DBMS_OUTPUT.PUT_LINE('Total errors: ' || v_error_count);
  
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error displaying error log: ' || SQLERRM);
END DISPLAY_ERROR_LOG;
/

-- 4. Test procedure with multiple exception scenarios
CREATE OR REPLACE PROCEDURE TEST_EXCEPTION_HANDLING AS
  v_result VARCHAR2(4000);
BEGIN
  DBMS_OUTPUT.PUT_LINE('=== Testing Exception Handling ===');
  
  -- Test 1: Valid parameters
  DBMS_OUTPUT.PUT_LINE('Test 1: Valid parameters');
  ADD_LOYALTY_POINTS_WITH_ERROR_HANDLING(1, 1, 100, v_result);
  DBMS_OUTPUT.PUT_LINE('Result: ' || v_result);
  
  -- Test 2: Invalid customer ID
  DBMS_OUTPUT.PUT_LINE('Test 2: Invalid customer ID');
  ADD_LOYALTY_POINTS_WITH_ERROR_HANDLING(999999, 1, 100, v_result);
  DBMS_OUTPUT.PUT_LINE('Result: ' || v_result);
  
  -- Test 3: Invalid purchase ID
  DBMS_OUTPUT.PUT_LINE('Test 3: Invalid purchase ID');
  ADD_LOYALTY_POINTS_WITH_ERROR_HANDLING(1, 999999, 100, v_result);
  DBMS_OUTPUT.PUT_LINE('Result: ' || v_result);
  
  -- Test 4: Invalid points value
  DBMS_OUTPUT.PUT_LINE('Test 4: Invalid points value');
  ADD_LOYALTY_POINTS_WITH_ERROR_HANDLING(1, 1, -50, v_result);
  DBMS_OUTPUT.PUT_LINE('Result: ' || v_result);
  
  -- Display error log
  DBMS_OUTPUT.PUT_LINE('');
  DISPLAY_ERROR_LOG(1);
  
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Test procedure failed: ' || SQLERRM);
END TEST_EXCEPTION_HANDLING;
/

-- Display object information
SELECT object_name, object_type, status 
FROM user_objects 
WHERE object_type IN ('PROCEDURE', 'FUNCTION', 'TABLE')
AND object_name IN ('ADD_LOYALTY_POINTS_WITH_ERROR_HANDLING', 'GET_CUSTOMER_POINTS_SAFE', 
                    'DISPLAY_ERROR_LOG', 'TEST_EXCEPTION_HANDLING', 'ERROR_LOG')
ORDER BY object_type, object_name;