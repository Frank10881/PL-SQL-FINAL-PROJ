-- Restriction Check Function for Customer Loyalty Points & Rewards Automation System
-- This script creates functions to check business restrictions for Phase VII

-- Connect as loyalty_owner user
-- CONN loyalty_owner/frank@localhost:1521/tue_26652_frank_loyalty_db

-- Function to check if current date is a weekday (Monday-Friday)
CREATE OR REPLACE FUNCTION IS_WEEKDAY RETURN VARCHAR2 AS
  v_day_of_week NUMBER;
BEGIN
  -- Get day of week (1=Sunday, 2=Monday, ..., 7=Saturday)
  SELECT TO_NUMBER(TO_CHAR(SYSDATE, 'D')) INTO v_day_of_week FROM DUAL;
  
  -- Return 'YES' for Monday(2) through Friday(6)
  IF v_day_of_week BETWEEN 2 AND 6 THEN
    RETURN 'YES';
  ELSE
    RETURN 'NO';
  END IF;
  
EXCEPTION
  WHEN OTHERS THEN
    RETURN 'ERROR';
END IS_WEEKDAY;
/

-- Function to check if current date is a weekend (Saturday-Sunday)
CREATE OR REPLACE FUNCTION IS_WEEKEND RETURN VARCHAR2 AS
BEGIN
  IF IS_WEEKDAY = 'YES' THEN
    RETURN 'NO';
  ELSE
    RETURN 'YES';
  END IF;
END IS_WEEKEND;
/

-- Function to check if current date is within the upcoming month
CREATE OR REPLACE FUNCTION IS_UPCOMING_MONTH RETURN VARCHAR2 AS
  v_current_date DATE;
  v_first_day_next_month DATE;
  v_last_day_next_month DATE;
BEGIN
  v_current_date := TRUNC(SYSDATE);
  
  -- First day of next month
  v_first_day_next_month := TRUNC(ADD_MONTHS(SYSDATE, 1), 'MM');
  
  -- Last day of next month
  v_last_day_next_month := LAST_DAY(ADD_MONTHS(SYSDATE, 1));
  
  -- Check if current date is within the upcoming month
  IF v_current_date BETWEEN v_first_day_next_month AND v_last_day_next_month THEN
    RETURN 'YES';
  ELSE
    RETURN 'NO';
  END IF;
  
EXCEPTION
  WHEN OTHERS THEN
    RETURN 'ERROR';
END IS_UPCOMING_MONTH;
/

-- Main function to check all business restrictions
CREATE OR REPLACE FUNCTION CHECK_BUSINESS_RESTRICTIONS RETURN VARCHAR2 AS
  v_is_weekday VARCHAR2(10);
  v_is_holiday VARCHAR2(10);
  v_is_upcoming_month VARCHAR2(10);
BEGIN
  -- Check if it's a weekday
  v_is_weekday := IS_WEEKDAY;
  
  -- Check if it's a holiday
  v_is_holiday := IS_HOLIDAY(SYSDATE);
  
  -- Check if it's in the upcoming month
  v_is_upcoming_month := IS_UPCOMING_MONTH;
  
  -- If any restriction applies, return the reason
  IF v_is_weekday = 'YES' THEN
    RETURN 'WEEKDAY_RESTRICTION';
  ELSIF v_is_holiday = 'YES' THEN
    RETURN 'HOLIDAY_RESTRICTION';
  ELSIF v_is_upcoming_month = 'YES' THEN
    RETURN 'UPCOMING_MONTH_RESTRICTION';
  ELSE
    RETURN 'ALLOWED';
  END IF;
  
EXCEPTION
  WHEN OTHERS THEN
    RETURN 'ERROR_CHECKING_RESTRICTIONS';
END CHECK_BUSINESS_RESTRICTIONS;
/

-- Function to get detailed restriction information
CREATE OR REPLACE FUNCTION GET_RESTRICTION_DETAILS RETURN VARCHAR2 AS
  v_details VARCHAR2(4000);
  v_is_weekday VARCHAR2(10);
  v_is_holiday VARCHAR2(10);
  v_is_upcoming_month VARCHAR2(10);
  v_holiday_name VARCHAR2(100);
BEGIN
  v_is_weekday := IS_WEEKDAY;
  v_is_holiday := IS_HOLIDAY(SYSDATE);
  v_is_upcoming_month := IS_UPCOMING_MONTH;
  
  -- Get holiday name if today is a holiday
  BEGIN
    SELECT holiday_name INTO v_holiday_name
    FROM HOLIDAYS
    WHERE holiday_date = TRUNC(SYSDATE)
    AND is_active = 'Y';
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      v_holiday_name := 'None';
    WHEN OTHERS THEN
      v_holiday_name := 'Error retrieving holiday name';
  END;
  
  v_details := 'Date: ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD Day') || CHR(10);
  v_details := v_details || 'Weekday: ' || v_is_weekday || CHR(10);
  v_details := v_details || 'Holiday: ' || v_is_holiday || ' (' || v_holiday_name || ')' || CHR(10);
  v_details := v_details || 'Upcoming Month: ' || v_is_upcoming_month || CHR(10);
  v_details := v_details || 'Overall Status: ' || CHECK_BUSINESS_RESTRICTIONS;
  
  RETURN v_details;
  
EXCEPTION
  WHEN OTHERS THEN
    RETURN 'Error getting restriction details: ' || SQLERRM;
END GET_RESTRICTION_DETAILS;
/

-- Function to check if an operation is allowed
CREATE OR REPLACE FUNCTION IS_OPERATION_ALLOWED (
  p_operation_type IN VARCHAR2 DEFAULT 'ANY'
) RETURN VARCHAR2 AS
  v_restriction_status VARCHAR2(100);
BEGIN
  v_restriction_status := CHECK_BUSINESS_RESTRICTIONS;
  
  -- If no restrictions apply, operation is allowed
  IF v_restriction_status = 'ALLOWED' THEN
    RETURN 'ALLOWED';
  ELSE
    RETURN 'DENIED:' || v_restriction_status;
  END IF;
  
EXCEPTION
  WHEN OTHERS THEN
    RETURN 'ERROR:Unable to check restrictions';
END IS_OPERATION_ALLOWED;
/

-- Procedure to validate operation permissions
CREATE OR REPLACE PROCEDURE VALIDATE_OPERATION_PERMISSION (
  p_table_name IN VARCHAR2,
  p_operation IN VARCHAR2,
  p_allowed OUT VARCHAR2,
  p_reason OUT VARCHAR2
) AS
  v_restriction_status VARCHAR2(100);
BEGIN
  v_restriction_status := CHECK_BUSINESS_RESTRICTIONS;
  
  IF v_restriction_status = 'ALLOWED' THEN
    p_allowed := 'YES';
    p_reason := 'Operation permitted';
  ELSE
    p_allowed := 'NO';
    p_reason := 'Operation denied due to: ' || v_restriction_status;
  END IF;
  
EXCEPTION
  WHEN OTHERS THEN
    p_allowed := 'ERROR';
    p_reason := 'Error validating permission: ' || SQLERRM;
END VALIDATE_OPERATION_PERMISSION;
/

-- Test the restriction check functions
DECLARE
  v_result VARCHAR2(100);
  v_allowed VARCHAR2(10);
  v_reason VARCHAR2(4000);
BEGIN
  DBMS_OUTPUT.PUT_LINE('Testing restriction check functions:');
  DBMS_OUTPUT.PUT_LINE('====================================');
  
  -- Test weekday check
  DBMS_OUTPUT.PUT_LINE('Is today a weekday? ' || IS_WEEKDAY);
  
  -- Test weekend check
  DBMS_OUTPUT.PUT_LINE('Is today a weekend? ' || IS_WEEKEND);
  
  -- Test holiday check
  DBMS_OUTPUT.PUT_LINE('Is today a holiday? ' || IS_HOLIDAY(SYSDATE));
  
  -- Test upcoming month check
  DBMS_OUTPUT.PUT_LINE('Is today in upcoming month? ' || IS_UPCOMING_MONTH);
  
  -- Test overall restriction check
  v_result := CHECK_BUSINESS_RESTRICTIONS;
  DBMS_OUTPUT.PUT_LINE('Business restrictions status: ' || v_result);
  
  -- Test detailed restriction information
  DBMS_OUTPUT.PUT_LINE('');
  DBMS_OUTPUT.PUT_LINE('Detailed restriction information:');
  DBMS_OUTPUT.PUT_LINE(GET_RESTRICTION_DETAILS);
  
  -- Test operation validation
  DBMS_OUTPUT.PUT_LINE('');
  DBMS_OUTPUT.PUT_LINE('Operation validation test:');
  VALIDATE_OPERATION_PERMISSION('CUSTOMERS', 'INSERT', v_allowed, v_reason);
  DBMS_OUTPUT.PUT_LINE('Allowed: ' || v_allowed);
  DBMS_OUTPUT.PUT_LINE('Reason: ' || v_reason);
  
  -- Test specific operation allowance
  DBMS_OUTPUT.PUT_LINE('');
  DBMS_OUTPUT.PUT_LINE('Is INSERT operation allowed? ' || IS_OPERATION_ALLOWED('INSERT'));
END;
/

-- Display restriction check information
SELECT 
  TO_CHAR(SYSDATE, 'YYYY-MM-DD Day') as current_date,
  IS_WEEKDAY as is_weekday,
  IS_HOLIDAY(SYSDATE) as is_holiday,
  IS_UPCOMING_MONTH as is_upcoming_month,
  CHECK_BUSINESS_RESTRICTIONS as restriction_status
FROM DUAL;