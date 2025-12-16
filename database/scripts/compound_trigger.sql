-- Compound Trigger for Customer Loyalty Points & Rewards Automation System
-- This script creates a compound trigger to enforce business restrictions for Phase VII

-- Connect as loyalty_owner user
-- CONN loyalty_owner/frank@localhost:1521/tue_26652_frank_loyalty_db

-- Compound trigger for CUSTOMERS table
CREATE OR REPLACE TRIGGER TRG_CUSTOMERS_COMPOUND
  FOR INSERT OR UPDATE OR DELETE ON CUSTOMERS
  COMPOUND TRIGGER
  
  -- Global variables
  v_operation VARCHAR2(10);
  v_row_key VARCHAR2(100);
  v_old_values CLOB;
  v_new_values CLOB;
  v_restriction_status VARCHAR2(100);
  v_audit_id NUMBER;
  
  -- BEFORE STATEMENT section
  BEFORE STATEMENT IS
  BEGIN
    -- Check business restrictions once per statement
    v_restriction_status := CHECK_BUSINESS_RESTRICTIONS;
    
    -- Log the start of the statement operation
    DBMS_OUTPUT.PUT_LINE('Compound trigger: Processing ' || 
                        CASE 
                          WHEN INSERTING THEN 'INSERT'
                          WHEN UPDATING THEN 'UPDATE'
                          WHEN DELETING THEN 'DELETE'
                        END || ' statement on CUSTOMERS table');
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Error in BEFORE STATEMENT: ' || SQLERRM);
  END BEFORE STATEMENT;
  
  -- BEFORE EACH ROW section
  BEFORE EACH ROW IS
  BEGIN
    -- Determine operation type
    IF INSERTING THEN
      v_operation := 'INSERT';
      v_row_key := 'NEW-' || :NEW.customer_id;
      v_new_values := '{"customer_id":' || :NEW.customer_id || 
                      ',"full_name":"' || :NEW.full_name || 
                      '","phone":"' || :NEW.phone || 
                      '","email":"' || :NEW.email || '"}';
    ELSIF UPDATING THEN
      v_operation := 'UPDATE';
      v_row_key := :OLD.customer_id;
      v_old_values := '{"customer_id":' || :OLD.customer_id || 
                      ',"full_name":"' || :OLD.full_name || 
                      '","phone":"' || :OLD.phone || 
                      '","email":"' || :OLD.email || '"}';
      v_new_values := '{"customer_id":' || :NEW.customer_id || 
                      ',"full_name":"' || :NEW.full_name || 
                      '","phone":"' || :NEW.phone || 
                      '","email":"' || :NEW.email || '"}';
    ELSIF DELETING THEN
      v_operation := 'DELETE';
      v_row_key := :OLD.customer_id;
      v_old_values := '{"customer_id":' || :OLD.customer_id || 
                      ',"full_name":"' || :OLD.full_name || 
                      '","phone":"' || :OLD.phone || 
                      '","email":"' || :OLD.email || '"}';
    END IF;
    
    -- Check restrictions and block if necessary
    IF v_restriction_status != 'ALLOWED' THEN
      LOG_BLOCKED_OPERATION('CUSTOMERS', v_operation, v_row_key, 
                           'Operation blocked due to: ' || v_restriction_status);
      RAISE_APPLICATION_ERROR(-20010, v_operation || ' operation on CUSTOMERS table is not allowed. Reason: ' || v_restriction_status);
    END IF;
    
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Error in BEFORE EACH ROW: ' || SQLERRM);
      RAISE;
  END BEFORE EACH ROW;
  
  -- AFTER EACH ROW section
  AFTER EACH ROW IS
  BEGIN
    -- Log successful operation
    IF v_restriction_status = 'ALLOWED' THEN
      LOG_SUCCESSFUL_OPERATION('CUSTOMERS', v_operation, v_row_key, v_old_values, v_new_values);
    END IF;
    
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Error in AFTER EACH ROW: ' || SQLERRM);
  END AFTER EACH ROW;
  
  -- AFTER STATEMENT section
  AFTER STATEMENT IS
  BEGIN
    -- Log completion of statement operation
    DBMS_OUTPUT.PUT_LINE('Compound trigger: Completed ' || v_operation || ' statement on CUSTOMERS table');
    
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Error in AFTER STATEMENT: ' || SQLERRM);
  END AFTER STATEMENT;
  
END TRG_CUSTOMERS_COMPOUND;
/

-- Compound trigger for PURCHASES table
CREATE OR REPLACE TRIGGER TRG_PURCHASES_COMPOUND
  FOR INSERT OR UPDATE OR DELETE ON PURCHASES
  COMPOUND TRIGGER
  
  -- Global variables
  v_operation VARCHAR2(10);
  v_row_key VARCHAR2(100);
  v_old_values CLOB;
  v_new_values CLOB;
  v_restriction_status VARCHAR2(100);
  
  -- BEFORE STATEMENT section
  BEFORE STATEMENT IS
  BEGIN
    -- Check business restrictions once per statement
    v_restriction_status := CHECK_BUSINESS_RESTRICTIONS;
    
    -- Log the start of the statement operation
    DBMS_OUTPUT.PUT_LINE('Compound trigger: Processing ' || 
                        CASE 
                          WHEN INSERTING THEN 'INSERT'
                          WHEN UPDATING THEN 'UPDATE'
                          WHEN DELETING THEN 'DELETE'
                        END || ' statement on PURCHASES table');
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Error in BEFORE STATEMENT: ' || SQLERRM);
  END BEFORE STATEMENT;
  
  -- BEFORE EACH ROW section
  BEFORE EACH ROW IS
  BEGIN
    -- Determine operation type
    IF INSERTING THEN
      v_operation := 'INSERT';
      v_row_key := 'NEW-' || :NEW.purchase_id;
      v_new_values := '{"purchase_id":' || :NEW.purchase_id || 
                      ',"customer_id":' || :NEW.customer_id || 
                      ',"purchase_date":"' || TO_CHAR(:NEW.purchase_date, 'YYYY-MM-DD') || 
                      '","amount":' || :NEW.amount || 
                      ',"store_location":"' || :NEW.store_location || '"}';
    ELSIF UPDATING THEN
      v_operation := 'UPDATE';
      v_row_key := :OLD.purchase_id;
      v_old_values := '{"purchase_id":' || :OLD.purchase_id || 
                      ',"customer_id":' || :OLD.customer_id || 
                      ',"purchase_date":"' || TO_CHAR(:OLD.purchase_date, 'YYYY-MM-DD') || 
                      '","amount":' || :OLD.amount || 
                      ',"store_location":"' || :OLD.store_location || '"}';
      v_new_values := '{"purchase_id":' || :NEW.purchase_id || 
                      ',"customer_id":' || :NEW.customer_id || 
                      ',"purchase_date":"' || TO_CHAR(:NEW.purchase_date, 'YYYY-MM-DD') || 
                      '","amount":' || :NEW.amount || 
                      ',"store_location":"' || :NEW.store_location || '"}';
    ELSIF DELETING THEN
      v_operation := 'DELETE';
      v_row_key := :OLD.purchase_id;
      v_old_values := '{"purchase_id":' || :OLD.purchase_id || 
                      ',"customer_id":' || :OLD.customer_id || 
                      ',"purchase_date":"' || TO_CHAR(:OLD.purchase_date, 'YYYY-MM-DD') || 
                      '","amount":' || :OLD.amount || 
                      ',"store_location":"' || :OLD.store_location || '"}';
    END IF;
    
    -- Check restrictions and block if necessary
    IF v_restriction_status != 'ALLOWED' THEN
      LOG_BLOCKED_OPERATION('PURCHASES', v_operation, v_row_key, 
                           'Operation blocked due to: ' || v_restriction_status);
      RAISE_APPLICATION_ERROR(-20011, v_operation || ' operation on PURCHASES table is not allowed. Reason: ' || v_restriction_status);
    END IF;
    
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Error in BEFORE EACH ROW: ' || SQLERRM);
      RAISE;
  END BEFORE EACH ROW;
  
  -- AFTER EACH ROW section
  AFTER EACH ROW IS
  BEGIN
    -- Log successful operation
    IF v_restriction_status = 'ALLOWED' THEN
      LOG_SUCCESSFUL_OPERATION('PURCHASES', v_operation, v_row_key, v_old_values, v_new_values);
    END IF;
    
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Error in AFTER EACH ROW: ' || SQLERRM);
  END AFTER EACH ROW;
  
  -- AFTER STATEMENT section
  AFTER STATEMENT IS
  BEGIN
    -- Log completion of statement operation
    DBMS_OUTPUT.PUT_LINE('Compound trigger: Completed ' || v_operation || ' statement on PURCHASES table');
    
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Error in AFTER STATEMENT: ' || SQLERRM);
  END AFTER STATEMENT;
  
END TRG_PURCHASES_COMPOUND;
/

-- Display compound trigger information
SELECT trigger_name, trigger_type, triggering_event, table_name, status
FROM user_triggers
WHERE trigger_name LIKE '%COMPOUND%'
ORDER BY table_name, trigger_name;

-- Test compound trigger functionality
DECLARE
  v_result VARCHAR2(4000);
BEGIN
  DBMS_OUTPUT.PUT_LINE('Testing compound trigger functionality:');
  DBMS_OUTPUT.PUT_LINE('====================================');
  
  -- This would normally trigger an error if restrictions are active
  -- For testing purposes, we'll catch the error and display it
  BEGIN
    INSERT INTO CUSTOMERS (customer_id, full_name, phone, email)
    VALUES (CUSTOMERS_SEQ.NEXTVAL, 'Test Customer Compound', '+1234567899', 'compound@test.com');
    
    DBMS_OUTPUT.PUT_LINE('Customer compound insert succeeded');
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Customer compound insert failed as expected: ' || SQLERRM);
      ROLLBACK;
  END;
  
  -- Test with multiple row insert
  BEGIN
    INSERT ALL
      INTO CUSTOMERS (customer_id, full_name, phone, email) VALUES (CUSTOMERS_SEQ.NEXTVAL, 'Test Customer 1', '+1000000001', 'test1@test.com')
      INTO CUSTOMERS (customer_id, full_name, phone, email) VALUES (CUSTOMERS_SEQ.NEXTVAL, 'Test Customer 2', '+1000000002', 'test2@test.com')
    SELECT * FROM DUAL;
    
    DBMS_OUTPUT.PUT_LINE('Multi-row customer insert succeeded');
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Multi-row customer insert failed as expected: ' || SQLERRM);
      ROLLBACK;
  END;
END;
/

-- Display recent audit logs to see compound trigger activity
SELECT audit_id, event_timestamp, table_name, operation, success_flag, error_message_preview
FROM AUDIT_LOG_SUMMARY
WHERE event_timestamp > SYSDATE - 1/24  -- Last hour
AND table_name IN ('CUSTOMERS', 'PURCHASES')
ORDER BY event_timestamp DESC;