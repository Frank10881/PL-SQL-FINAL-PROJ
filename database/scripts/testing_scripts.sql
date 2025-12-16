-- Testing Scripts for Customer Loyalty Points & Rewards Automation System
-- This script tests all Phase VII components including triggers, restrictions, and auditing

-- Connect as loyalty_owner user
-- CONN loyalty_owner/frank@localhost:1521/tue_26652_frank_loyalty_db

SET SERVEROUTPUT ON;
SET VERIFY OFF;

PROMPT === Phase VII Testing Script ===
PROMPT

-- 1. Test Holiday Management
PROMPT === Testing Holiday Management ===
DECLARE
  v_result VARCHAR2(4000);
BEGIN
  DBMS_OUTPUT.PUT_LINE('1. Testing holiday functions:');
  
  -- Test if today is a holiday
  DBMS_OUTPUT.PUT_LINE('   Today is a holiday: ' || IS_HOLIDAY(SYSDATE));
  
  -- Test a known holiday
  DBMS_OUTPUT.PUT_LINE('   Christmas 2025 is a holiday: ' || IS_HOLIDAY(TO_DATE('2025-12-25', 'YYYY-MM-DD')));
  
  -- Test adding a new holiday
  ADD_HOLIDAY(TO_DATE('2026-06-19', 'YYYY-MM-DD'), 'Juneteenth Test', 'Test holiday addition', v_result);
  DBMS_OUTPUT.PUT_LINE('   Add holiday result: ' || v_result);
  
  -- Test deactivating a holiday
  DEACTIVATE_HOLIDAY(TO_DATE('2026-06-19', 'YYYY-MM-DD'), v_result);
  DBMS_OUTPUT.PUT_LINE('   Deactivate holiday result: ' || v_result);
END;
/

PROMPT
-- 2. Test Restriction Functions
PROMPT === Testing Restriction Functions ===
BEGIN
  DBMS_OUTPUT.PUT_LINE('2. Testing restriction functions:');
  
  -- Test weekday check
  DBMS_OUTPUT.PUT_LINE('   Is today a weekday: ' || IS_WEEKDAY);
  
  -- Test weekend check
  DBMS_OUTPUT.PUT_LINE('   Is today a weekend: ' || IS_WEEKEND);
  
  -- Test upcoming month check
  DBMS_OUTPUT.PUT_LINE('   Is today in upcoming month: ' || IS_UPCOMING_MONTH);
  
  -- Test overall restriction check
  DBMS_OUTPUT.PUT_LINE('   Overall restriction status: ' || CHECK_BUSINESS_RESTRICTIONS);
  
  -- Test detailed restriction information
  DBMS_OUTPUT.PUT_LINE('   Detailed restriction info:');
  DBMS_OUTPUT.PUT_LINE('   ' || REPLACE(GET_RESTRICTION_DETAILS, CHR(10), CHR(10) || '   '));
  
  -- Test operation allowance
  DBMS_OUTPUT.PUT_LINE('   Is INSERT operation allowed: ' || IS_OPERATION_ALLOWED('INSERT'));
END;
/

PROMPT
-- 3. Test Audit Logging
PROMPT === Testing Audit Logging ===
DECLARE
  v_audit_id NUMBER;
  v_allowed VARCHAR2(10);
  v_reason VARCHAR2(4000);
BEGIN
  DBMS_OUTPUT.PUT_LINE('3. Testing audit logging:');
  
  -- Test successful operation logging
  LOG_SUCCESSFUL_OPERATION('TEST_TABLE', 'INSERT', 'TEST-001', NULL, '{"test_id":1,"test_name":"Test Record"}');
  DBMS_OUTPUT.PUT_LINE('   Successful operation logged');
  
  -- Test blocked operation logging
  LOG_BLOCKED_OPERATION('TEST_TABLE', 'UPDATE', 'TEST-001', 'Test restriction violation');
  DBMS_OUTPUT.PUT_LINE('   Blocked operation logged');
  
  -- Test direct audit logging
  v_audit_id := LOG_AUDIT_EVENT(
    p_table_name => 'TEST_TABLE',
    p_operation => 'DELETE',
    p_row_key => 'TEST-001',
    p_old_values => '{"test_id":1}',
    p_new_values => NULL,
    p_success_flag => 'Y'
  );
  DBMS_OUTPUT.PUT_LINE('   Direct audit log entry created with ID: ' || v_audit_id);
  
  -- Test operation validation
  VALIDATE_OPERATION_PERMISSION('CUSTOMERS', 'INSERT', v_allowed, v_reason);
  DBMS_OUTPUT.PUT_LINE('   Operation validation - Allowed: ' || v_allowed || ', Reason: ' || v_reason);
END;
/

PROMPT
-- 4. Test Trigger Restrictions
PROMPT === Testing Trigger Restrictions ===
BEGIN
  DBMS_OUTPUT.PUT_LINE('4. Testing trigger restrictions:');
  
  -- Test INSERT on CUSTOMERS table (should be blocked if restrictions apply)
  DBMS_OUTPUT.PUT_LINE('   Attempting to insert into CUSTOMERS table:');
  BEGIN
    INSERT INTO CUSTOMERS (customer_id, full_name, phone, email)
    VALUES (CUSTOMERS_SEQ.NEXTVAL, 'Test Customer', '+1234567890', 'test@example.com');
    DBMS_OUTPUT.PUT_LINE('   Insert succeeded');
    ROLLBACK;
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('   Insert failed as expected: ' || SQLERRM);
      ROLLBACK;
  END;
  
  -- Test INSERT on PURCHASES table (should be blocked if restrictions apply)
  DBMS_OUTPUT.PUT_LINE('   Attempting to insert into PURCHASES table:');
  BEGIN
    INSERT INTO PURCHASES (purchase_id, customer_id, purchase_date, amount, store_location)
    VALUES (PURCHASES_SEQ.NEXTVAL, 1, SYSDATE, 100.00, 'Test Store');
    DBMS_OUTPUT.PUT_LINE('   Insert succeeded');
    ROLLBACK;
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('   Insert failed as expected: ' || SQLERRM);
      ROLLBACK;
  END;
END;
/

PROMPT
-- 5. Test Compound Triggers
PROMPT === Testing Compound Triggers ===
BEGIN
  DBMS_OUTPUT.PUT_LINE('5. Testing compound triggers:');
  
  -- Test compound trigger on CUSTOMERS table
  DBMS_OUTPUT.PUT_LINE('   Attempting multi-row insert on CUSTOMERS table:');
  BEGIN
    INSERT ALL
      INTO CUSTOMERS (customer_id, full_name, phone, email) VALUES (CUSTOMERS_SEQ.NEXTVAL, 'Test Customer 1', '+1000000001', 'test1@example.com')
      INTO CUSTOMERS (customer_id, full_name, phone, email) VALUES (CUSTOMERS_SEQ.NEXTVAL, 'Test Customer 2', '+1000000002', 'test2@example.com')
    SELECT * FROM DUAL;
    DBMS_OUTPUT.PUT_LINE('   Multi-row insert succeeded');
    ROLLBACK;
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('   Multi-row insert failed as expected: ' || SQLERRM);
      ROLLBACK;
  END;
END;
/

PROMPT
-- 6. Test Specific Requirements
PROMPT === Testing Specific Requirements ===
BEGIN
  DBMS_OUTPUT.PUT_LINE('6. Testing specific requirements:');
  
  -- Requirement: Trigger blocks INSERT on weekday (DENIED)
  DBMS_OUTPUT.PUT_LINE('   Weekday restriction test:');
  IF IS_WEEKDAY = 'YES' THEN
    DBMS_OUTPUT.PUT_LINE('   Today is a weekday - operations should be DENIED');
  ELSE
    DBMS_OUTPUT.PUT_LINE('   Today is not a weekday - operations may be ALLOWED');
  END IF;
  
  -- Requirement: Trigger allows INSERT on weekend (ALLOWED)
  DBMS_OUTPUT.PUT_LINE('   Weekend allowance test:');
  IF IS_WEEKEND = 'YES' THEN
    DBMS_OUTPUT.PUT_LINE('   Today is a weekend - operations should be ALLOWED');
  ELSE
    DBMS_OUTPUT.PUT_LINE('   Today is not a weekend - operations may be DENIED');
  END IF;
  
  -- Requirement: Trigger blocks INSERT on holiday (DENIED)
  DBMS_OUTPUT.PUT_LINE('   Holiday restriction test:');
  IF IS_HOLIDAY(SYSDATE) = 'YES' THEN
    DBMS_OUTPUT.PUT_LINE('   Today is a holiday - operations should be DENIED');
  ELSE
    DBMS_OUTPUT.PUT_LINE('   Today is not a holiday - operations may be ALLOWED');
  END IF;
  
  -- Requirement: Audit log captures all attempts
  DBMS_OUTPUT.PUT_LINE('   Audit log verification:');
  DBMS_OUTPUT.PUT_LINE('   Recent audit entries:');
  FOR rec IN (SELECT audit_id, event_timestamp, table_name, operation, success_flag 
              FROM AUDIT_LOG 
              WHERE event_timestamp > SYSDATE - 1/24  -- Last hour
              ORDER BY event_timestamp DESC
              FETCH FIRST 5 ROWS ONLY) LOOP
    DBMS_OUTPUT.PUT_LINE('   ID: ' || rec.audit_id || 
                        ', Table: ' || rec.table_name || 
                        ', Operation: ' || rec.operation || 
                        ', Success: ' || rec.success_flag);
  END LOOP;
  
  -- Requirement: Error messages are clear
  DBMS_OUTPUT.PUT_LINE('   Error message clarity test:');
  DBMS_OUTPUT.PUT_LINE('   Current restriction status: ' || CHECK_BUSINESS_RESTRICTIONS);
  
  -- Requirement: User info properly recorded
  DBMS_OUTPUT.PUT_LINE('   User info recording test:');
  DECLARE
    v_user_name VARCHAR2(30);
    v_ip_address VARCHAR2(45);
  BEGIN
    SELECT SYS_CONTEXT('USERENV', 'SESSION_USER'),
           SYS_CONTEXT('USERENV', 'IP_ADDRESS')
    INTO v_user_name, v_ip_address
    FROM DUAL;
    
    DBMS_OUTPUT.PUT_LINE('   Current user: ' || v_user_name);
    DBMS_OUTPUT.PUT_LINE('   Client IP: ' || v_ip_address);
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('   Error retrieving user info: ' || SQLERRM);
  END;
END;
/

PROMPT
-- 7. Performance Testing
PROMPT === Performance Testing ===
DECLARE
  v_start_time TIMESTAMP;
  v_end_time TIMESTAMP;
  v_elapsed_time NUMBER;
  v_result VARCHAR2(100);
BEGIN
  DBMS_OUTPUT.PUT_LINE('7. Performance testing:');
  
  -- Test restriction check performance
  v_start_time := SYSTIMESTAMP;
  
  FOR i IN 1..1000 LOOP
    v_result := CHECK_BUSINESS_RESTRICTIONS;
  END LOOP;
  
  v_end_time := SYSTIMESTAMP;
  v_elapsed_time := EXTRACT(SECOND FROM (v_end_time - v_start_time)) * 1000;
  
  DBMS_OUTPUT.PUT_LINE('   1000 restriction checks took ' || ROUND(v_elapsed_time, 2) || ' milliseconds');
  DBMS_OUTPUT.PUT_LINE('   Average per check: ' || ROUND(v_elapsed_time/1000, 4) || ' milliseconds');
END;
/

PROMPT
-- 8. Clean Up Test Data
PROMPT === Cleaning Up Test Data ===
BEGIN
  DBMS_OUTPUT.PUT_LINE('8. Cleaning up test data:');
  
  -- Clean old audit logs (older than 1 day for testing)
  DECLARE
    v_deleted_count NUMBER;
  BEGIN
    CLEAN_AUDIT_LOG(1, v_deleted_count);
    DBMS_OUTPUT.PUT_LINE('   Cleaned ' || v_deleted_count || ' old audit records');
  END;
  
  DBMS_OUTPUT.PUT_LINE('   Cleanup completed');
END;
/

PROMPT
-- 9. Summary Report
PROMPT === Summary Report ===
BEGIN
  DBMS_OUTPUT.PUT_LINE('9. Summary report:');
  
  -- Display audit log statistics
  FOR rec IN (SELECT operation, success_flag, COUNT(*) as count
              FROM AUDIT_LOG
              GROUP BY operation, success_flag
              ORDER BY operation, success_flag) LOOP
    DBMS_OUTPUT.PUT_LINE('   ' || rec.operation || ' (' || rec.success_flag || '): ' || rec.count);
  END LOOP;
  
  -- Display total audit records
  DECLARE
    v_total_count NUMBER;
  BEGIN
    SELECT COUNT(*) INTO v_total_count FROM AUDIT_LOG;
    DBMS_OUTPUT.PUT_LINE('   Total audit records: ' || v_total_count);
  END;
  
  DBMS_OUTPUT.PUT_LINE('   Testing completed successfully');
END;
/

PROMPT
PROMPT === Phase VII Testing Completed ===
PROMPT Please review the output above to verify all requirements are met.
PROMPT Check the AUDIT_LOG table for complete audit trail information.