-- Audit Logging Function for Customer Loyalty Points & Rewards Automation System
-- This script creates functions for logging audit events

-- Connect as loyalty_owner user
-- CONN loyalty_owner/frank@localhost:1521/tue_26652_frank_loyalty_db

-- Function to log audit events
CREATE OR REPLACE FUNCTION LOG_AUDIT_EVENT (
  p_table_name IN VARCHAR2,
  p_operation IN VARCHAR2,
  p_row_key IN VARCHAR2,
  p_old_values IN CLOB DEFAULT NULL,
  p_new_values IN CLOB DEFAULT NULL,
  p_success_flag IN VARCHAR2 DEFAULT 'Y',
  p_error_message IN VARCHAR2 DEFAULT NULL
) RETURN NUMBER AS
  PRAGMA AUTONOMOUS_TRANSACTION;
  
  v_audit_id NUMBER;
  v_user_name VARCHAR2(30);
  v_ip_address VARCHAR2(45);
  v_session_id VARCHAR2(30);
  v_client_info VARCHAR2(100);
BEGIN
  -- Get session information
  SELECT SYS_CONTEXT('USERENV', 'SESSION_USER'),
         SYS_CONTEXT('USERENV', 'IP_ADDRESS'),
         SYS_CONTEXT('USERENV', 'SESSIONID'),
         SYS_CONTEXT('USERENV', 'CLIENT_INFO')
  INTO v_user_name, v_ip_address, v_session_id, v_client_info
  FROM DUAL;
  
  -- Insert audit record
  INSERT INTO AUDIT_LOG (
    table_name,
    operation,
    row_key,
    old_values,
    new_values,
    user_name,
    ip_address,
    session_id,
    client_info,
    success_flag,
    error_message
  ) VALUES (
    UPPER(p_table_name),
    UPPER(p_operation),
    p_row_key,
    p_old_values,
    p_new_values,
    v_user_name,
    v_ip_address,
    v_session_id,
    v_client_info,
    UPPER(p_success_flag),
    p_error_message
  )
  RETURNING audit_id INTO v_audit_id;
  
  COMMIT;
  RETURN v_audit_id;
  
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    -- Log the error to DBMS_OUTPUT for debugging
    DBMS_OUTPUT.PUT_LINE('Audit logging error: ' || SQLERRM);
    RETURN -1;
END LOG_AUDIT_EVENT;
/

-- Function to convert a record to JSON format for audit logging
CREATE OR REPLACE FUNCTION RECORD_TO_JSON (
  p_table_name IN VARCHAR2,
  p_operation IN VARCHAR2,
  p_row_key IN VARCHAR2
) RETURN CLOB AS
  v_json CLOB;
BEGIN
  -- This is a simplified implementation
  -- In a real system, you would dynamically generate JSON based on the actual record
  v_json := '{"table":"' || p_table_name || '","operation":"' || p_operation || '","row_key":"' || p_row_key || '"}';
  RETURN v_json;
  
EXCEPTION
  WHEN OTHERS THEN
    RETURN '{"error":"Failed to generate JSON for audit logging"}';
END RECORD_TO_JSON;
/

-- Function to get the current user's IP address
CREATE OR REPLACE FUNCTION GET_CLIENT_IP RETURN VARCHAR2 AS
  v_ip_address VARCHAR2(45);
BEGIN
  SELECT SYS_CONTEXT('USERENV', 'IP_ADDRESS')
  INTO v_ip_address
  FROM DUAL;
  
  RETURN v_ip_address;
  
EXCEPTION
  WHEN OTHERS THEN
    RETURN 'UNKNOWN';
END GET_CLIENT_IP;
/

-- Function to check if audit logging is enabled
CREATE OR REPLACE FUNCTION IS_AUDIT_ENABLED RETURN VARCHAR2 AS
BEGIN
  -- In a real system, this might check a configuration table
  -- For now, we'll always return 'Y' to indicate audit logging is enabled
  RETURN 'Y';
  
EXCEPTION
  WHEN OTHERS THEN
    RETURN 'N';
END IS_AUDIT_ENABLED;
/

-- Procedure to log a successful operation
CREATE OR REPLACE PROCEDURE LOG_SUCCESSFUL_OPERATION (
  p_table_name IN VARCHAR2,
  p_operation IN VARCHAR2,
  p_row_key IN VARCHAR2,
  p_old_values IN CLOB DEFAULT NULL,
  p_new_values IN CLOB DEFAULT NULL
) AS
  v_audit_id NUMBER;
BEGIN
  IF IS_AUDIT_ENABLED = 'Y' THEN
    v_audit_id := LOG_AUDIT_EVENT(
      p_table_name => p_table_name,
      p_operation => p_operation,
      p_row_key => p_row_key,
      p_old_values => p_old_values,
      p_new_values => p_new_values,
      p_success_flag => 'Y',
      p_error_message => NULL
    );
    
    IF v_audit_id > 0 THEN
      DBMS_OUTPUT.PUT_LINE('Audit log entry ' || v_audit_id || ' created for ' || p_operation || ' on ' || p_table_name);
    ELSE
      DBMS_OUTPUT.PUT_LINE('Failed to create audit log entry for ' || p_operation || ' on ' || p_table_name);
    END IF;
  ELSE
    DBMS_OUTPUT.PUT_LINE('Audit logging is disabled');
  END IF;
  
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error in LOG_SUCCESSFUL_OPERATION: ' || SQLERRM);
END LOG_SUCCESSFUL_OPERATION;
/

-- Procedure to log a blocked operation
CREATE OR REPLACE PROCEDURE LOG_BLOCKED_OPERATION (
  p_table_name IN VARCHAR2,
  p_operation IN VARCHAR2,
  p_row_key IN VARCHAR2,
  p_reason IN VARCHAR2
) AS
  v_audit_id NUMBER;
BEGIN
  v_audit_id := LOG_AUDIT_EVENT(
    p_table_name => p_table_name,
    p_operation => p_operation,
    p_row_key => p_row_key,
    p_old_values => NULL,
    p_new_values => NULL,
    p_success_flag => 'N',
    p_error_message => p_reason
  );
  
  IF v_audit_id > 0 THEN
    DBMS_OUTPUT.PUT_LINE('Blocked operation logged with audit ID ' || v_audit_id || ': ' || p_reason);
  ELSE
    DBMS_OUTPUT.PUT_LINE('Failed to log blocked operation: ' || p_reason);
  END IF;
  
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error in LOG_BLOCKED_OPERATION: ' || SQLERRM);
END LOG_BLOCKED_OPERATION;
/

-- Test the audit logging functions
DECLARE
  v_audit_id NUMBER;
BEGIN
  DBMS_OUTPUT.PUT_LINE('Testing audit logging functions:');
  
  -- Test successful operation logging
  LOG_SUCCESSFUL_OPERATION('CUSTOMERS', 'INSERT', 'CUST-001', NULL, '{"customer_id":1,"full_name":"Test Customer"}');
  
  -- Test blocked operation logging
  LOG_BLOCKED_OPERATION('LOYALTY_POINTS', 'INSERT', 'POINT-001', 'Operation blocked due to business rule violation');
  
  -- Test the basic audit logging function
  v_audit_id := LOG_AUDIT_EVENT(
    p_table_name => 'REWARDS',
    p_operation => 'UPDATE',
    p_row_key => 'REWARD-001',
    p_old_values => '{"points_required":100}',
    p_new_values => '{"points_required":150}',
    p_success_flag => 'Y'
  );
  
  DBMS_OUTPUT.PUT_LINE('Direct audit log entry created with ID: ' || v_audit_id);
  
  -- View recent audit logs
  DBMS_OUTPUT.PUT_LINE('Recent audit log entries:');
  FOR rec IN (SELECT * FROM AUDIT_LOG_SUMMARY WHERE ROWNUM <= 5) LOOP
    DBMS_OUTPUT.PUT_LINE('ID: ' || rec.audit_id || 
                        ', Table: ' || rec.table_name || 
                        ', Operation: ' || rec.operation || 
                        ', Success: ' || rec.success_flag);
  END LOOP;
END;
/

-- Display audit log information
SELECT COUNT(*) as total_audit_records FROM AUDIT_LOG;
SELECT operation, COUNT(*) as count FROM AUDIT_LOG GROUP BY operation;