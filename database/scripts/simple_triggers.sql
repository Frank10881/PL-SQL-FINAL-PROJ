-- Simple Triggers for Customer Loyalty Points & Rewards Automation System
-- This script creates triggers to enforce business restrictions for Phase VII

-- Connect as loyalty_owner user
-- CONN loyalty_owner/frank@localhost:1521/tue_26652_frank_loyalty_db

-- Trigger for CUSTOMERS table - BEFORE INSERT
CREATE OR REPLACE TRIGGER TRG_CUSTOMERS_BI
  BEFORE INSERT ON CUSTOMERS
  FOR EACH ROW
DECLARE
  v_permission_status VARCHAR2(100);
BEGIN
  v_permission_status := CHECK_BUSINESS_RESTRICTIONS;
  
  IF v_permission_status != 'ALLOWED' THEN
    LOG_BLOCKED_OPERATION('CUSTOMERS', 'INSERT', 'NEW-' || :NEW.customer_id, 
                         'Insert operation blocked due to: ' || v_permission_status);
    RAISE_APPLICATION_ERROR(-20001, 'INSERT operation on CUSTOMERS table is not allowed. Reason: ' || v_permission_status);
  ELSE
    LOG_SUCCESSFUL_OPERATION('CUSTOMERS', 'INSERT', :NEW.customer_id, NULL, 
                            '{"customer_id":' || :NEW.customer_id || ',"full_name":"' || :NEW.full_name || '"}');
  END IF;
END TRG_CUSTOMERS_BI;
/

-- Trigger for CUSTOMERS table - BEFORE UPDATE
CREATE OR REPLACE TRIGGER TRG_CUSTOMERS_BU
  BEFORE UPDATE ON CUSTOMERS
  FOR EACH ROW
DECLARE
  v_permission_status VARCHAR2(100);
BEGIN
  v_permission_status := CHECK_BUSINESS_RESTRICTIONS;
  
  IF v_permission_status != 'ALLOWED' THEN
    LOG_BLOCKED_OPERATION('CUSTOMERS', 'UPDATE', :OLD.customer_id, 
                         'Update operation blocked due to: ' || v_permission_status);
    RAISE_APPLICATION_ERROR(-20002, 'UPDATE operation on CUSTOMERS table is not allowed. Reason: ' || v_permission_status);
  ELSE
    LOG_SUCCESSFUL_OPERATION('CUSTOMERS', 'UPDATE', :OLD.customer_id, 
                            '{"customer_id":' || :OLD.customer_id || ',"full_name":"' || :OLD.full_name || '"}',
                            '{"customer_id":' || :NEW.customer_id || ',"full_name":"' || :NEW.full_name || '"}');
  END IF;
END TRG_CUSTOMERS_BU;
/

-- Trigger for CUSTOMERS table - BEFORE DELETE
CREATE OR REPLACE TRIGGER TRG_CUSTOMERS_BD
  BEFORE DELETE ON CUSTOMERS
  FOR EACH ROW
DECLARE
  v_permission_status VARCHAR2(100);
BEGIN
  v_permission_status := CHECK_BUSINESS_RESTRICTIONS;
  
  IF v_permission_status != 'ALLOWED' THEN
    LOG_BLOCKED_OPERATION('CUSTOMERS', 'DELETE', :OLD.customer_id, 
                         'Delete operation blocked due to: ' || v_permission_status);
    RAISE_APPLICATION_ERROR(-20003, 'DELETE operation on CUSTOMERS table is not allowed. Reason: ' || v_permission_status);
  ELSE
    LOG_SUCCESSFUL_OPERATION('CUSTOMERS', 'DELETE', :OLD.customer_id, 
                            '{"customer_id":' || :OLD.customer_id || ',"full_name":"' || :OLD.full_name || '"}', NULL);
  END IF;
END TRG_CUSTOMERS_BD;
/

-- Trigger for PURCHASES table - BEFORE INSERT
CREATE OR REPLACE TRIGGER TRG_PURCHASES_BI
  BEFORE INSERT ON PURCHASES
  FOR EACH ROW
DECLARE
  v_permission_status VARCHAR2(100);
BEGIN
  v_permission_status := CHECK_BUSINESS_RESTRICTIONS;
  
  IF v_permission_status != 'ALLOWED' THEN
    LOG_BLOCKED_OPERATION('PURCHASES', 'INSERT', 'NEW-' || :NEW.purchase_id, 
                         'Insert operation blocked due to: ' || v_permission_status);
    RAISE_APPLICATION_ERROR(-20004, 'INSERT operation on PURCHASES table is not allowed. Reason: ' || v_permission_status);
  ELSE
    LOG_SUCCESSFUL_OPERATION('PURCHASES', 'INSERT', :NEW.purchase_id, NULL, 
                            '{"purchase_id":' || :NEW.purchase_id || ',"customer_id":' || :NEW.customer_id || ',"amount":' || :NEW.amount || '}');
  END IF;
END TRG_PURCHASES_BI;
/

-- Trigger for LOYALTY_POINTS table - BEFORE INSERT
CREATE OR REPLACE TRIGGER TRG_LOYALTY_POINTS_BI
  BEFORE INSERT ON LOYALTY_POINTS
  FOR EACH ROW
DECLARE
  v_permission_status VARCHAR2(100);
BEGIN
  v_permission_status := CHECK_BUSINESS_RESTRICTIONS;
  
  IF v_permission_status != 'ALLOWED' THEN
    LOG_BLOCKED_OPERATION('LOYALTY_POINTS', 'INSERT', 'NEW-' || :NEW.point_id, 
                         'Insert operation blocked due to: ' || v_permission_status);
    RAISE_APPLICATION_ERROR(-20005, 'INSERT operation on LOYALTY_POINTS table is not allowed. Reason: ' || v_permission_status);
  ELSE
    LOG_SUCCESSFUL_OPERATION('LOYALTY_POINTS', 'INSERT', :NEW.point_id, NULL, 
                            '{"point_id":' || :NEW.point_id || ',"customer_id":' || :NEW.customer_id || ',"points":' || :NEW.points || '}');
  END IF;
END TRG_LOYALTY_POINTS_BI;
/

-- Trigger for REWARDS table - BEFORE INSERT
CREATE OR REPLACE TRIGGER TRG_REWARDS_BI
  BEFORE INSERT ON REWARDS
  FOR EACH ROW
DECLARE
  v_permission_status VARCHAR2(100);
BEGIN
  v_permission_status := CHECK_BUSINESS_RESTRICTIONS;
  
  IF v_permission_status != 'ALLOWED' THEN
    LOG_BLOCKED_OPERATION('REWARDS', 'INSERT', 'NEW-' || :NEW.reward_id, 
                         'Insert operation blocked due to: ' || v_permission_status);
    RAISE_APPLICATION_ERROR(-20006, 'INSERT operation on REWARDS table is not allowed. Reason: ' || v_permission_status);
  ELSE
    LOG_SUCCESSFUL_OPERATION('REWARDS', 'INSERT', :NEW.reward_id, NULL, 
                            '{"reward_id":' || :NEW.reward_id || ',"reward_name":"' || :NEW.reward_name || '"}');
  END IF;
END TRG_REWARDS_BI;
/

-- Trigger for REDEMPTIONS table - BEFORE INSERT
CREATE OR REPLACE TRIGGER TRG_REDEMPTIONS_BI
  BEFORE INSERT ON REDEMPTIONS
  FOR EACH ROW
DECLARE
  v_permission_status VARCHAR2(100);
BEGIN
  v_permission_status := CHECK_BUSINESS_RESTRICTIONS;
  
  IF v_permission_status != 'ALLOWED' THEN
    LOG_BLOCKED_OPERATION('REDEMPTIONS', 'INSERT', 'NEW-' || :NEW.redemption_id, 
                         'Insert operation blocked due to: ' || v_permission_status);
    RAISE_APPLICATION_ERROR(-20007, 'INSERT operation on REDEMPTIONS table is not allowed. Reason: ' || v_permission_status);
  ELSE
    LOG_SUCCESSFUL_OPERATION('REDEMPTIONS', 'INSERT', :NEW.redemption_id, NULL, 
                            '{"redemption_id":' || :NEW.redemption_id || ',"customer_id":' || :NEW.customer_id || ',"reward_id":' || :NEW.reward_id || '}');
  END IF;
END TRG_REDEMPTIONS_BI;
/

-- Trigger for HOLIDAYS table - BEFORE INSERT
CREATE OR REPLACE TRIGGER TRG_HOLIDAYS_BI
  BEFORE INSERT ON HOLIDAYS
  FOR EACH ROW
DECLARE
  v_permission_status VARCHAR2(100);
BEGIN
  v_permission_status := CHECK_BUSINESS_RESTRICTIONS;
  
  IF v_permission_status != 'ALLOWED' THEN
    LOG_BLOCKED_OPERATION('HOLIDAYS', 'INSERT', 'NEW-' || :NEW.holiday_id, 
                         'Insert operation blocked due to: ' || v_permission_status);
    RAISE_APPLICATION_ERROR(-20008, 'INSERT operation on HOLIDAYS table is not allowed. Reason: ' || v_permission_status);
  ELSE
    LOG_SUCCESSFUL_OPERATION('HOLIDAYS', 'INSERT', :NEW.holiday_id, NULL, 
                            '{"holiday_id":' || :NEW.holiday_id || ',"holiday_name":"' || :NEW.holiday_name || '"}');
  END IF;
END TRG_HOLIDAYS_BI;
/

-- Display trigger information
SELECT trigger_name, trigger_type, triggering_event, table_name, status
FROM user_triggers
WHERE trigger_name LIKE 'TRG_%'
ORDER BY table_name, trigger_name;

-- Test trigger functionality
DECLARE
  v_result VARCHAR2(4000);
BEGIN
  DBMS_OUTPUT.PUT_LINE('Testing trigger functionality:');
  DBMS_OUTPUT.PUT_LINE('=============================');
  
  -- This would normally trigger an error if restrictions are active
  -- For testing purposes, we'll catch the error and display it
  BEGIN
    INSERT INTO CUSTOMERS (customer_id, full_name, phone, email)
    VALUES (CUSTOMERS_SEQ.NEXTVAL, 'Test Customer', '+1234567890', 'test@example.com');
    
    DBMS_OUTPUT.PUT_LINE('Customer insert succeeded');
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Customer insert failed as expected: ' || SQLERRM);
      ROLLBACK;
  END;
  
  -- Test with purchases
  BEGIN
    INSERT INTO PURCHASES (purchase_id, customer_id, purchase_date, amount, store_location)
    VALUES (PURCHASES_SEQ.NEXTVAL, 1, SYSDATE, 100.00, 'Test Store');
    
    DBMS_OUTPUT.PUT_LINE('Purchase insert succeeded');
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Purchase insert failed as expected: ' || SQLERRM);
      ROLLBACK;
  END;
END;
/

-- Display recent audit logs to see trigger activity
SELECT audit_id, event_timestamp, table_name, operation, success_flag, error_message_preview
FROM AUDIT_LOG_SUMMARY
WHERE event_timestamp > SYSDATE - 1/24  -- Last hour
ORDER BY event_timestamp DESC;