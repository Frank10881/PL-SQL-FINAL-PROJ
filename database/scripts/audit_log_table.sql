-- Audit Log Table for Customer Loyalty Points & Rewards Automation System
-- This script creates the audit log table for tracking all database modifications

-- Connect as loyalty_owner user
-- CONN loyalty_owner/frank@localhost:1521/tue_26652_frank_loyalty_db

-- Drop existing AUDIT_LOG table if it exists
BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE AUDIT_LOG CASCADE CONSTRAINTS';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE != -942 THEN
      RAISE;
    END IF;
END;
/

-- Create sequence for AUDIT_LOG table
BEGIN
  EXECUTE IMMEDIATE 'DROP SEQUENCE AUDIT_LOG_SEQ';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE != -2289 THEN
      RAISE;
    END IF;
END;
/

CREATE SEQUENCE AUDIT_LOG_SEQ START WITH 1 INCREMENT BY 1;

-- Create AUDIT_LOG table
CREATE TABLE AUDIT_LOG (
  audit_id NUMBER GENERATED ALWAYS AS IDENTITY,
  event_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  user_name VARCHAR2(30),
  table_name VARCHAR2(30),
  operation VARCHAR2(10) CONSTRAINT AUDIT_LOG_OPERATION_CHK CHECK (operation IN ('INSERT', 'UPDATE', 'DELETE')),
  row_key VARCHAR2(100),
  old_values CLOB,
  new_values CLOB,
  ip_address VARCHAR2(45),
  session_id VARCHAR2(30),
  client_info VARCHAR2(100),
  success_flag VARCHAR2(1) DEFAULT 'Y' CONSTRAINT AUDIT_LOG_SUCCESS_CHK CHECK (success_flag IN ('Y', 'N')),
  error_message VARCHAR2(4000)
);

-- Create indexes for performance
CREATE INDEX AUDIT_LOG_TIMESTAMP_IX ON AUDIT_LOG(event_timestamp);
CREATE INDEX AUDIT_LOG_USER_IX ON AUDIT_LOG(user_name);
CREATE INDEX AUDIT_LOG_TABLE_IX ON AUDIT_LOG(table_name);
CREATE INDEX AUDIT_LOG_OPERATION_IX ON AUDIT_LOG(operation);

-- Add comments to describe the table and columns
COMMENT ON TABLE AUDIT_LOG IS 'Audit trail for tracking all INSERT, UPDATE, and DELETE operations on loyalty system tables';
COMMENT ON COLUMN AUDIT_LOG.audit_id IS 'Unique identifier for each audit record';
COMMENT ON COLUMN AUDIT_LOG.event_timestamp IS 'Timestamp when the operation occurred';
COMMENT ON COLUMN AUDIT_LOG.user_name IS 'Database user who performed the operation';
COMMENT ON COLUMN AUDIT_LOG.table_name IS 'Name of the table affected by the operation';
COMMENT ON COLUMN AUDIT_LOG.operation IS 'Type of operation: INSERT, UPDATE, or DELETE';
COMMENT ON COLUMN AUDIT_LOG.row_key IS 'Identifier for the affected row (usually primary key)';
COMMENT ON COLUMN AUDIT_LOG.old_values IS 'JSON representation of old values before UPDATE or DELETE';
COMMENT ON COLUMN AUDIT_LOG.new_values IS 'JSON representation of new values after INSERT or UPDATE';
COMMENT ON COLUMN AUDIT_LOG.ip_address IS 'IP address of the client machine';
COMMENT ON COLUMN AUDIT_LOG.session_id IS 'Database session identifier';
COMMENT ON COLUMN AUDIT_LOG.client_info IS 'Additional client information';
COMMENT ON COLUMN AUDIT_LOG.success_flag IS 'Indicates if the operation was successful (Y) or blocked (N)';
COMMENT ON COLUMN AUDIT_LOG.error_message IS 'Error message if the operation failed';

-- Create a view for easier querying of audit logs
CREATE OR REPLACE VIEW AUDIT_LOG_SUMMARY AS
SELECT 
  audit_id,
  event_timestamp,
  user_name,
  table_name,
  operation,
  row_key,
  SUBSTR(old_values, 1, 100) as old_values_preview,
  SUBSTR(new_values, 1, 100) as new_values_preview,
  ip_address,
  success_flag,
  SUBSTR(error_message, 1, 100) as error_message_preview
FROM AUDIT_LOG
ORDER BY event_timestamp DESC;

-- Create a procedure to clean old audit records
CREATE OR REPLACE PROCEDURE CLEAN_AUDIT_LOG (
  p_days_to_keep IN NUMBER DEFAULT 90,
  p_deleted_count OUT NUMBER
) AS
BEGIN
  DELETE FROM AUDIT_LOG
  WHERE event_timestamp < SYSDATE - p_days_to_keep;
  
  p_deleted_count := SQL%ROWCOUNT;
  COMMIT;
  
  DBMS_OUTPUT.PUT_LINE('Cleaned ' || p_deleted_count || ' audit records older than ' || p_days_to_keep || ' days');
  
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    p_deleted_count := 0;
    DBMS_OUTPUT.PUT_LINE('Error cleaning audit log: ' || SQLERRM);
END CLEAN_AUDIT_LOG;
/

-- Create a procedure to export audit logs
CREATE OR REPLACE PROCEDURE EXPORT_AUDIT_LOG (
  p_start_date IN DATE DEFAULT SYSDATE - 30,
  p_end_date IN DATE DEFAULT SYSDATE,
  p_table_name IN VARCHAR2 DEFAULT NULL
) AS
  CURSOR audit_cursor IS
    SELECT *
    FROM AUDIT_LOG
    WHERE event_timestamp BETWEEN p_start_date AND p_end_date
    AND (p_table_name IS NULL OR table_name = p_table_name)
    ORDER BY event_timestamp;
    
  v_audit_record audit_cursor%ROWTYPE;
  v_record_count NUMBER := 0;
BEGIN
  DBMS_OUTPUT.PUT_LINE('Audit Log Export');
  DBMS_OUTPUT.PUT_LINE('================');
  DBMS_OUTPUT.PUT_LINE('Date Range: ' || TO_CHAR(p_start_date, 'YYYY-MM-DD') || ' to ' || TO_CHAR(p_end_date, 'YYYY-MM-DD'));
  DBMS_OUTPUT.PUT_LINE('Table Filter: ' || NVL(p_table_name, 'ALL'));
  DBMS_OUTPUT.PUT_LINE('');
  
  FOR v_audit_record IN audit_cursor LOOP
    v_record_count := v_record_count + 1;
    DBMS_OUTPUT.PUT_LINE(
      'ID: ' || v_audit_record.audit_id || 
      ', Time: ' || TO_CHAR(v_audit_record.event_timestamp, 'YYYY-MM-DD HH24:MI:SS') ||
      ', User: ' || v_audit_record.user_name ||
      ', Table: ' || v_audit_record.table_name ||
      ', Operation: ' || v_audit_record.operation ||
      ', Success: ' || v_audit_record.success_flag
    );
    
    -- Limit output for readability
    IF v_record_count >= 100 THEN
      DBMS_OUTPUT.PUT_LINE('... (export truncated for brevity)');
      EXIT;
    END IF;
  END LOOP;
  
  DBMS_OUTPUT.PUT_LINE('');
  DBMS_OUTPUT.PUT_LINE('Total Records: ' || v_record_count);
  
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error exporting audit log: ' || SQLERRM);
END EXPORT_AUDIT_LOG;
/

-- Display table structure
DESC AUDIT_LOG;

-- Display some sample data (will be empty initially)
SELECT * FROM AUDIT_LOG_SUMMARY WHERE ROWNUM <= 5;

-- Display table information
SELECT table_name, num_rows, last_analyzed 
FROM user_tables 
WHERE table_name = 'AUDIT_LOG';