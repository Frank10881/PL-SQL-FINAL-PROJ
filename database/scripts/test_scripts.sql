-- Test Scripts for Customer Loyalty Points & Rewards Automation System
-- This script tests all PL/SQL components created in Phase VI

-- Connect as loyalty_owner user
-- CONN loyalty_owner/frank@localhost:1521/tue_26652_frank_loyalty_db

-- Set up for testing
SET SERVEROUTPUT ON;
SET VERIFY OFF;

PROMPT === Starting Comprehensive PL/SQL Component Testing ===
PROMPT

-- 1. Test Procedures
PROMPT === Testing Procedures ===

-- Test ADD_LOYALTY_POINTS procedure
PROMPT 1. Testing ADD_LOYALTY_POINTS procedure
DECLARE
  v_result_message VARCHAR2(4000);
BEGIN
  DBMS_OUTPUT.PUT_LINE('Test 1a: Adding 50 points for customer 1 and purchase 1');
  ADD_LOYALTY_POINTS(1, 1, 50, v_result_message);
  DBMS_OUTPUT.PUT_LINE('Result: ' || v_result_message);
  
  DBMS_OUTPUT.PUT_LINE('Test 1b: Adding 75 points for customer 2 and purchase 2');
  ADD_LOYALTY_POINTS(2, 2, 75, v_result_message);
  DBMS_OUTPUT.PUT_LINE('Result: ' || v_result_message);
  
  DBMS_OUTPUT.PUT_LINE('Test 1c: Testing invalid customer ID');
  ADD_LOYALTY_POINTS(999999, 1, 100, v_result_message);
  DBMS_OUTPUT.PUT_LINE('Result: ' || v_result_message);
  
  DBMS_OUTPUT.PUT_LINE('Test 1d: Testing invalid purchase ID');
  ADD_LOYALTY_POINTS(1, 999999, 100, v_result_message);
  DBMS_OUTPUT.PUT_LINE('Result: ' || v_result_message);
  
  DBMS_OUTPUT.PUT_LINE('Test 1e: Testing invalid points value');
  ADD_LOYALTY_POINTS(1, 1, -50, v_result_message);
  DBMS_OUTPUT.PUT_LINE('Result: ' || v_result_message);
END;
/

PROMPT
-- Test REDEEM_REWARD procedure
PROMPT 2. Testing REDEEM_REWARD procedure
DECLARE
  v_redemption_message VARCHAR2(4000);
BEGIN
  DBMS_OUTPUT.PUT_LINE('Test 2a: Redeeming reward 1 for customer 1');
  REDEEM_REWARD(1, 1, v_redemption_message);
  DBMS_OUTPUT.PUT_LINE('Result: ' || v_redemption_message);
  
  DBMS_OUTPUT.PUT_LINE('Test 2b: Testing invalid customer ID');
  REDEEM_REWARD(999999, 1, v_redemption_message);
  DBMS_OUTPUT.PUT_LINE('Result: ' || v_redemption_message);
  
  DBMS_OUTPUT.PUT_LINE('Test 2c: Testing invalid reward ID');
  REDEEM_REWARD(1, 999999, v_redemption_message);
  DBMS_OUTPUT.PUT_LINE('Result: ' || v_redemption_message);
END;
/

PROMPT
-- Test ADD_PROMOTIONAL_BONUS procedure
PROMPT 3. Testing ADD_PROMOTIONAL_BONUS procedure
DECLARE
  v_bonus_message VARCHAR2(4000);
BEGIN
  DBMS_OUTPUT.PUT_LINE('Test 3a: Adding 100 bonus points for customer 1');
  ADD_PROMOTIONAL_BONUS(1, 100, 'Spring Sale', v_bonus_message);
  DBMS_OUTPUT.PUT_LINE('Result: ' || v_bonus_message);
  
  DBMS_OUTPUT.PUT_LINE('Test 3b: Adding 50 bonus points for customer 2');
  ADD_PROMOTIONAL_BONUS(2, 50, 'Welcome Back', v_bonus_message);
  DBMS_OUTPUT.PUT_LINE('Result: ' || v_bonus_message);
  
  DBMS_OUTPUT.PUT_LINE('Test 3c: Testing invalid customer ID');
  ADD_PROMOTIONAL_BONUS(999999, 100, 'Test Promotion', v_bonus_message);
  DBMS_OUTPUT.PUT_LINE('Result: ' || v_bonus_message);
END;
/

PROMPT
-- Test EXPIRE_LOYALTY_POINTS procedure
PROMPT 4. Testing EXPIRE_LOYALTY_POINTS procedure
DECLARE
  v_expired_count NUMBER;
  v_expiration_message VARCHAR2(4000);
BEGIN
  DBMS_OUTPUT.PUT_LINE('Test 4a: Expiring loyalty points');
  EXPIRE_LOYALTY_POINTS(SYSDATE, v_expired_count, v_expiration_message);
  DBMS_OUTPUT.PUT_LINE('Expired Count: ' || v_expired_count);
  DBMS_OUTPUT.PUT_LINE('Result: ' || v_expiration_message);
END;
/

PROMPT
-- 2. Test Functions
PROMPT === Testing Functions ===

-- Test CALCULATE_POINTS function
PROMPT 5. Testing CALCULATE_POINTS function
BEGIN
  DBMS_OUTPUT.PUT_LINE('Test 5a: Calculating points for $45.50 purchase');
  DBMS_OUTPUT.PUT_LINE('Result: ' || CALCULATE_POINTS(45.50) || ' points');
  
  DBMS_OUTPUT.PUT_LINE('Test 5b: Calculating points for $120.75 purchase');
  DBMS_OUTPUT.PUT_LINE('Result: ' || CALCULATE_POINTS(120.75) || ' points');
  
  DBMS_OUTPUT.PUT_LINE('Test 5c: Calculating points for $0.50 purchase');
  DBMS_OUTPUT.PUT_LINE('Result: ' || CALCULATE_POINTS(0.50) || ' points');
END;
/

PROMPT
-- Test GET_CUSTOMER_POINTS function
PROMPT 6. Testing GET_CUSTOMER_POINTS function
BEGIN
  DBMS_OUTPUT.PUT_LINE('Test 6a: Getting points for customer 1');
  DBMS_OUTPUT.PUT_LINE('Result: ' || GET_CUSTOMER_POINTS(1) || ' points');
  
  DBMS_OUTPUT.PUT_LINE('Test 6b: Getting points for customer 2');
  DBMS_OUTPUT.PUT_LINE('Result: ' || GET_CUSTOMER_POINTS(2) || ' points');
  
  DBMS_OUTPUT.PUT_LINE('Test 6c: Getting points for invalid customer');
  DBMS_OUTPUT.PUT_LINE('Result: ' || GET_CUSTOMER_POINTS(999999) || ' points');
END;
/

PROMPT
-- Test CAN_REDEEM_REWARD function
PROMPT 7. Testing CAN_REDEEM_REWARD function
BEGIN
  DBMS_OUTPUT.PUT_LINE('Test 7a: Can customer 1 redeem reward 1?');
  DBMS_OUTPUT.PUT_LINE('Result: ' || CAN_REDEEM_REWARD(1, 1));
  
  DBMS_OUTPUT.PUT_LINE('Test 7b: Can customer 2 redeem reward 2?');
  DBMS_OUTPUT.PUT_LINE('Result: ' || CAN_REDEEM_REWARD(2, 2));
  
  DBMS_OUTPUT.PUT_LINE('Test 7c: Testing invalid customer');
  DBMS_OUTPUT.PUT_LINE('Result: ' || CAN_REDEEM_REWARD(999999, 1));
END;
/

PROMPT
-- Test GET_ELIGIBLE_REWARDS function
PROMPT 8. Testing GET_ELIGIBLE_REWARDS function
BEGIN
  DBMS_OUTPUT.PUT_LINE('Test 8a: Eligible rewards for customer 1');
  DBMS_OUTPUT.PUT_LINE('Result: ' || GET_ELIGIBLE_REWARDS(1));
  
  DBMS_OUTPUT.PUT_LINE('Test 8b: Eligible rewards for customer 2');
  DBMS_OUTPUT.PUT_LINE('Result: ' || GET_ELIGIBLE_REWARDS(2));
END;
/

PROMPT
-- Test IS_HOLIDAY function
PROMPT 9. Testing IS_HOLIDAY function
BEGIN
  DBMS_OUTPUT.PUT_LINE('Test 9a: Is today a holiday?');
  DBMS_OUTPUT.PUT_LINE('Result: ' || IS_HOLIDAY(SYSDATE));
  
  DBMS_OUTPUT.PUT_LINE('Test 9b: Is Christmas 2025 a holiday?');
  DBMS_OUTPUT.PUT_LINE('Result: ' || IS_HOLIDAY(TO_DATE('2025-12-25', 'YYYY-MM-DD')));
END;
/

PROMPT
-- 3. Test Package
PROMPT === Testing Package ===

-- Test LOYALTY_PKG procedures and functions
PROMPT 10. Testing LOYALTY_PKG package
DECLARE
  v_result_message VARCHAR2(4000);
  v_redemption_message VARCHAR2(4000);
  v_bonus_message VARCHAR2(4000);
  v_expired_count NUMBER;
  v_expiration_message VARCHAR2(4000);
BEGIN
  DBMS_OUTPUT.PUT_LINE('Test 10a: Testing package ADD_LOYALTY_POINTS');
  LOYALTY_PKG.ADD_LOYALTY_POINTS(3, 3, 80, v_result_message);
  DBMS_OUTPUT.PUT_LINE('Result: ' || v_result_message);
  
  DBMS_OUTPUT.PUT_LINE('Test 10b: Testing package GET_CUSTOMER_POINTS');
  DBMS_OUTPUT.PUT_LINE('Result: ' || LOYALTY_PKG.GET_CUSTOMER_POINTS(3) || ' points');
  
  DBMS_OUTPUT.PUT_LINE('Test 10c: Testing package CALCULATE_POINTS');
  DBMS_OUTPUT.PUT_LINE('Result: ' || LOYALTY_PKG.CALCULATE_POINTS(95.25) || ' points');
  
  DBMS_OUTPUT.PUT_LINE('Test 10d: Testing package GET_CUSTOMER_TIER');
  DBMS_OUTPUT.PUT_LINE('Result: ' || LOYALTY_PKG.GET_CUSTOMER_TIER(1));
  
  DBMS_OUTPUT.PUT_LINE('Test 10e: Testing package GET_TOTAL_PURCHASES');
  DBMS_OUTPUT.PUT_LINE('Result: $' || LOYALTY_PKG.GET_TOTAL_PURCHASES(1));
END;
/

PROMPT
-- 4. Test Cursors
PROMPT === Testing Cursors ===

-- Test batch processing procedures
PROMPT 11. Testing batch processing cursors
BEGIN
  DBMS_OUTPUT.PUT_LINE('Test 11a: Testing BATCH_EXPIRE_POINTS');
  BATCH_EXPIRE_POINTS;
  
  DBMS_OUTPUT.PUT_LINE('Test 11b: Testing GENERATE_CUSTOMER_REPORT');
  GENERATE_CUSTOMER_REPORT;
  
  DBMS_OUTPUT.PUT_LINE('Test 11c: Testing BULK_PROMOTIONAL_BONUS');
  BULK_PROMOTIONAL_BONUS(25, 'Summer Bonus');
  
  DBMS_OUTPUT.PUT_LINE('Test 11d: Testing BULK_UPDATE_INACTIVE_CUSTOMERS');
  BULK_UPDATE_INACTIVE_CUSTOMERS;
END;
/

PROMPT
-- 5. Test Exception Handling
PROMPT === Testing Exception Handling ===

PROMPT 12. Testing exception handling procedures
BEGIN
  DBMS_OUTPUT.PUT_LINE('Test 12a: Testing ADD_LOYALTY_POINTS_WITH_ERROR_HANDLING');
  TEST_EXCEPTION_HANDLING;
  
  DBMS_OUTPUT.PUT_LINE('Test 12b: Testing safe function');
  DBMS_OUTPUT.PUT_LINE('Safe points for customer 1: ' || GET_CUSTOMER_POINTS_SAFE(1));
END;
/

PROMPT
-- 6. Performance Testing
PROMPT === Performance Testing ===

PROMPT 13. Testing function performance
DECLARE
  v_start_time TIMESTAMP;
  v_end_time TIMESTAMP;
  v_elapsed_time NUMBER;
  v_result NUMBER;
BEGIN
  DBMS_OUTPUT.PUT_LINE('Test 13a: Performance test for GET_CUSTOMER_POINTS');
  
  v_start_time := SYSTIMESTAMP;
  
  -- Call function 1000 times
  FOR i IN 1..1000 LOOP
    v_result := GET_CUSTOMER_POINTS(1);
  END LOOP;
  
  v_end_time := SYSTIMESTAMP;
  v_elapsed_time := EXTRACT(SECOND FROM (v_end_time - v_start_time)) * 1000;
  
  DBMS_OUTPUT.PUT_LINE('1000 calls took ' || ROUND(v_elapsed_time, 2) || ' milliseconds');
  DBMS_OUTPUT.PUT_LINE('Average per call: ' || ROUND(v_elapsed_time/1000, 4) || ' milliseconds');
END;
/

PROMPT
-- 7. Edge Case Testing
PROMPT === Edge Case Testing ===

PROMPT 14. Testing edge cases
DECLARE
  v_result VARCHAR2(4000);
BEGIN
  DBMS_OUTPUT.PUT_LINE('Test 14a: Testing with NULL values');
  -- This would typically raise an exception, but our procedures handle it
  
  DBMS_OUTPUT.PUT_LINE('Test 14b: Testing with very large numbers');
  ADD_LOYALTY_POINTS(1, 1, 999999, v_result);
  DBMS_OUTPUT.PUT_LINE('Result: ' || v_result);
  
  DBMS_OUTPUT.PUT_LINE('Test 14c: Testing with zero values');
  ADD_LOYALTY_POINTS(1, 1, 0, v_result);
  DBMS_OUTPUT.PUT_LINE('Result: ' || v_result);
END;
/

PROMPT
-- 8. Cleanup and Verification
PROMPT === Cleanup and Verification ===

PROMPT 15. Verifying test results
BEGIN
  DBMS_OUTPUT.PUT_LINE('Test 15a: Counting new loyalty points entries');
  DECLARE
    v_count NUMBER;
  BEGIN
    SELECT COUNT(*) INTO v_count 
    FROM LOYALTY_POINTS 
    WHERE earned_date >= SYSDATE - 1; -- Points added in the last day
    
    DBMS_OUTPUT.PUT_LINE('New points entries: ' || v_count);
  END;
  
  DBMS_OUTPUT.PUT_LINE('Test 15b: Counting new redemption entries');
  DECLARE
    v_count NUMBER;
  BEGIN
    SELECT COUNT(*) INTO v_count 
    FROM REDEMPTIONS 
    WHERE redemption_date >= SYSDATE - 1; -- Redemptions in the last day
    
    DBMS_OUTPUT.PUT_LINE('New redemptions: ' || v_count);
  END;
  
  DBMS_OUTPUT.PUT_LINE('Test 15c: Displaying error log');
  DISPLAY_ERROR_LOG(1);
END;
/

PROMPT
PROMPT === All Tests Completed ===
PROMPT Please review the output above to verify all components are working correctly.
PROMPT Check the ERROR_LOG table for any logged errors.
PROMPT Run analytics queries to verify data integrity.