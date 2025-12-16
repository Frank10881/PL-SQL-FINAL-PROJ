-- Holiday Management for Customer Loyalty Points & Rewards Automation System
-- This script creates and manages holiday data for Phase VII restrictions

-- Connect as loyalty_owner user
-- CONN loyalty_owner/frank@localhost:1521/tue_26652_frank_loyalty_db

-- Drop existing HOLIDAYS table if it exists
BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE HOLIDAYS CASCADE CONSTRAINTS';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE != -942 THEN
      RAISE;
    END IF;
END;
/

-- Create sequence for HOLIDAYS table
BEGIN
  EXECUTE IMMEDIATE 'DROP SEQUENCE HOLIDAYS_SEQ';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE != -2289 THEN
      RAISE;
    END IF;
END;
/

CREATE SEQUENCE HOLIDAYS_SEQ START WITH 1 INCREMENT BY 1;

-- Create HOLIDAYS table
CREATE TABLE HOLIDAYS (
  holiday_id NUMBER(6) CONSTRAINT HOLIDAYS_PK PRIMARY KEY,
  holiday_date DATE CONSTRAINT HOLIDAYS_DATE_NN NOT NULL,
  holiday_name VARCHAR2(100) CONSTRAINT HOLIDAYS_NAME_NN NOT NULL,
  is_active VARCHAR2(1) DEFAULT 'Y' CONSTRAINT HOLIDAYS_ACTIVE_NN NOT NULL 
    CONSTRAINT HOLIDAYS_ACTIVE_CHK CHECK (is_active IN ('Y', 'N')),
  description VARCHAR2(500),
  created_date DATE DEFAULT SYSDATE,
  modified_date DATE DEFAULT SYSDATE
);

-- Create indexes for performance
CREATE INDEX HOLIDAYS_DATE_IX ON HOLIDAYS(holiday_date);
CREATE INDEX HOLIDAYS_ACTIVE_IX ON HOLIDAYS(is_active);

-- Insert sample holiday data for upcoming months (as required by Phase VII)
INSERT INTO HOLIDAYS (holiday_id, holiday_date, holiday_name, is_active, description) 
VALUES (HOLIDAYS_SEQ.NEXTVAL, TO_DATE('2025-12-25', 'YYYY-MM-DD'), 'Christmas Day', 'Y', 'Annual Christmas celebration');

INSERT INTO HOLIDAYS (holiday_id, holiday_date, holiday_name, is_active, description) 
VALUES (HOLIDAYS_SEQ.NEXTVAL, TO_DATE('2026-01-01', 'YYYY-MM-DD'), 'New Year''s Day', 'Y', 'Annual New Year celebration');

INSERT INTO HOLIDAYS (holiday_id, holiday_date, holiday_name, is_active, description) 
VALUES (HOLIDAYS_SEQ.NEXTVAL, TO_DATE('2026-01-19', 'YYYY-MM-DD'), 'Martin Luther King Jr. Day', 'Y', 'Federal holiday honoring MLK');

INSERT INTO HOLIDAYS (holiday_id, holiday_date, holiday_name, is_active, description) 
VALUES (HOLIDAYS_SEQ.NEXTVAL, TO_DATE('2026-02-14', 'YYYY-MM-DD'), 'Valentine''s Day', 'Y', 'Valentine''s Day celebration');

INSERT INTO HOLIDAYS (holiday_id, holiday_date, holiday_name, is_active, description) 
VALUES (HOLIDAYS_SEQ.NEXTVAL, TO_DATE('2026-02-22', 'YYYY-MM-DD'), 'Presidents'' Day', 'Y', 'Federal holiday honoring US Presidents');

INSERT INTO HOLIDAYS (holiday_id, holiday_date, holiday_name, is_active, description) 
VALUES (HOLIDAYS_SEQ.NEXTVAL, TO_DATE('2026-03-17', 'YYYY-MM-DD'), 'St. Patrick''s Day', 'Y', 'Traditional St. Patrick''s Day celebration');

INSERT INTO HOLIDAYS (holiday_id, holiday_date, holiday_name, is_active, description) 
VALUES (HOLIDAYS_SEQ.NEXTVAL, TO_DATE('2026-04-01', 'YYYY-MM-DD'), 'April Fools'' Day', 'Y', 'April Fools'' Day');

INSERT INTO HOLIDAYS (holiday_id, holiday_date, holiday_name, is_active, description) 
VALUES (HOLIDAYS_SEQ.NEXTVAL, TO_DATE('2026-05-25', 'YYYY-MM-DD'), 'Memorial Day', 'Y', 'Federal Memorial Day holiday');

INSERT INTO HOLIDAYS (holiday_id, holiday_date, holiday_name, is_active, description) 
VALUES (HOLIDAYS_SEQ.NEXTVAL, TO_DATE('2026-07-04', 'YYYY-MM-DD'), 'Independence Day', 'Y', 'US Independence Day');

INSERT INTO HOLIDAYS (holiday_id, holiday_date, holiday_name, is_active, description) 
VALUES (HOLIDAYS_SEQ.NEXTVAL, TO_DATE('2026-09-07', 'YYYY-MM-DD'), 'Labor Day', 'Y', 'Federal Labor Day holiday');

INSERT INTO HOLIDAYS (holiday_id, holiday_date, holiday_name, is_active, description) 
VALUES (HOLIDAYS_SEQ.NEXTVAL, TO_DATE('2026-10-12', 'YYYY-MM-DD'), 'Columbus Day', 'Y', 'Federal Columbus Day holiday');

INSERT INTO HOLIDAYS (holiday_id, holiday_date, holiday_name, is_active, description) 
VALUES (HOLIDAYS_SEQ.NEXTVAL, TO_DATE('2026-10-31', 'YYYY-MM-DD'), 'Halloween', 'Y', 'Halloween celebration');

INSERT INTO HOLIDAYS (holiday_id, holiday_date, holiday_name, is_active, description) 
VALUES (HOLIDAYS_SEQ.NEXTVAL, TO_DATE('2026-11-11', 'YYYY-MM-DD'), 'Veterans Day', 'Y', 'Federal Veterans Day holiday');

INSERT INTO HOLIDAYS (holiday_id, holiday_date, holiday_name, is_active, description) 
VALUES (HOLIDAYS_SEQ.NEXTVAL, TO_DATE('2026-11-26', 'YYYY-MM-DD'), 'Thanksgiving Day', 'Y', 'Annual Thanksgiving celebration');

INSERT INTO HOLIDAYS (holiday_id, holiday_date, holiday_name, is_active, description) 
VALUES (HOLIDAYS_SEQ.NEXTVAL, TO_DATE('2026-12-25', 'YYYY-MM-DD'), 'Christmas Day', 'Y', 'Annual Christmas celebration');

-- Procedure to add a new holiday
CREATE OR REPLACE PROCEDURE ADD_HOLIDAY (
  p_holiday_date IN DATE,
  p_holiday_name IN VARCHAR2,
  p_description IN VARCHAR2 DEFAULT NULL,
  p_result_message OUT VARCHAR2
) AS
  v_holiday_id NUMBER;
BEGIN
  -- Generate new holiday ID
  SELECT HOLIDAYS_SEQ.NEXTVAL INTO v_holiday_id FROM DUAL;
  
  -- Insert holiday record
  INSERT INTO HOLIDAYS (
    holiday_id,
    holiday_date,
    holiday_name,
    is_active,
    description
  ) VALUES (
    v_holiday_id,
    p_holiday_date,
    p_holiday_name,
    'Y',
    p_description
  );
  
  COMMIT;
  p_result_message := 'Success: Holiday "' || p_holiday_name || '" added for ' || TO_CHAR(p_holiday_date, 'YYYY-MM-DD');
  
EXCEPTION
  WHEN DUP_VAL_ON_INDEX THEN
    ROLLBACK;
    p_result_message := 'Error: Holiday already exists for this date';
  WHEN OTHERS THEN
    ROLLBACK;
    p_result_message := 'Error: ' || SQLERRM;
END ADD_HOLIDAY;
/

-- Procedure to deactivate a holiday
CREATE OR REPLACE PROCEDURE DEACTIVATE_HOLIDAY (
  p_holiday_date IN DATE,
  p_result_message OUT VARCHAR2
) AS
BEGIN
  UPDATE HOLIDAYS
  SET is_active = 'N',
      modified_date = SYSDATE
  WHERE holiday_date = p_holiday_date;
  
  IF SQL%ROWCOUNT > 0 THEN
    COMMIT;
    p_result_message := 'Success: Holiday for ' || TO_CHAR(p_holiday_date, 'YYYY-MM-DD') || ' deactivated';
  ELSE
    p_result_message := 'Warning: No holiday found for ' || TO_CHAR(p_holiday_date, 'YYYY-MM-DD');
  END IF;
  
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    p_result_message := 'Error: ' || SQLERRM;
END DEACTIVATE_HOLIDAY;
/

-- Function to check if a date is a holiday
CREATE OR REPLACE FUNCTION IS_HOLIDAY (
  p_check_date IN DATE
) RETURN VARCHAR2 AS
  v_holiday_count NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_holiday_count
  FROM HOLIDAYS
  WHERE holiday_date = TRUNC(p_check_date)
  AND is_active = 'Y';
  
  IF v_holiday_count > 0 THEN
    RETURN 'YES';
  ELSE
    RETURN 'NO';
  END IF;
  
EXCEPTION
  WHEN OTHERS THEN
    RETURN 'ERROR';
END IS_HOLIDAY;
/

-- Display holiday information
SELECT holiday_id, holiday_date, holiday_name, is_active 
FROM HOLIDAYS 
ORDER BY holiday_date;

-- Test the holiday functions
DECLARE
  v_result VARCHAR2(4000);
BEGIN
  DBMS_OUTPUT.PUT_LINE('Testing holiday management functions:');
  
  DBMS_OUTPUT.PUT_LINE('Is today a holiday? ' || IS_HOLIDAY(SYSDATE));
  DBMS_OUTPUT.PUT_LINE('Is Christmas 2025 a holiday? ' || IS_HOLIDAY(TO_DATE('2025-12-25', 'YYYY-MM-DD')));
  
  ADD_HOLIDAY(TO_DATE('2026-06-19', 'YYYY-MM-DD'), 'Juneteenth', 'Celebration of emancipation', v_result);
  DBMS_OUTPUT.PUT_LINE(v_result);
END;
/