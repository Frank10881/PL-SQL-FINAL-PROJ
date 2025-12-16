-- Audit Queries for Customer Loyalty Points & Rewards Automation System
-- This script contains queries for analyzing audit logs and monitoring system activity

-- Connect as loyalty_owner user
-- CONN loyalty_owner/frank@localhost:1521/tue_26652_frank_loyalty_db

-- 1. Recent audit log entries
SELECT audit_id, event_timestamp, user_name, table_name, operation, success_flag, error_message_preview
FROM AUDIT_LOG_SUMMARY
WHERE event_timestamp >= SYSDATE - 7  -- Last 7 days
ORDER BY event_timestamp DESC;

-- 2. Failed operations analysis
SELECT event_timestamp, user_name, table_name, operation, error_message_preview, COUNT(*) as failure_count
FROM AUDIT_LOG_SUMMARY
WHERE success_flag = 'N'
AND event_timestamp >= SYSDATE - 30  -- Last 30 days
GROUP BY event_timestamp, user_name, table_name, operation, error_message_preview
ORDER BY failure_count DESC;

-- 3. User activity analysis
SELECT user_name, operation, table_name, COUNT(*) as operation_count
FROM AUDIT_LOG_SUMMARY
WHERE event_timestamp >= SYSDATE - 30  -- Last 30 days
GROUP BY user_name, operation, table_name
ORDER BY user_name, operation_count DESC;

-- 4. Table modification frequency
SELECT table_name, operation, COUNT(*) as modification_count
FROM AUDIT_LOG_SUMMARY
WHERE event_timestamp >= SYSDATE - 30  -- Last 30 days
GROUP BY table_name, operation
ORDER BY modification_count DESC;

-- 5. Time-based activity patterns
SELECT 
  TO_CHAR(event_timestamp, 'YYYY-MM-DD') as date,
  TO_CHAR(event_timestamp, 'HH24') as hour,
  COUNT(*) as activity_count
FROM AUDIT_LOG
WHERE event_timestamp >= SYSDATE - 7  -- Last 7 days
GROUP BY TO_CHAR(event_timestamp, 'YYYY-MM-DD'), TO_CHAR(event_timestamp, 'HH24')
ORDER BY date, hour;

-- 6. Blocked operations by reason
SELECT error_message, COUNT(*) as block_count
FROM AUDIT_LOG_SUMMARY
WHERE success_flag = 'N'
AND event_timestamp >= SYSDATE - 30  -- Last 30 days
GROUP BY error_message
ORDER BY block_count DESC;

-- 7. IP address activity
SELECT ip_address, user_name, COUNT(*) as connection_count
FROM AUDIT_LOG_SUMMARY
WHERE ip_address IS NOT NULL
AND event_timestamp >= SYSDATE - 30  -- Last 30 days
GROUP BY ip_address, user_name
ORDER BY connection_count DESC;

-- 8. Session activity analysis
SELECT session_id, user_name, COUNT(*) as session_activity_count
FROM AUDIT_LOG_SUMMARY
WHERE session_id IS NOT NULL
AND event_timestamp >= SYSDATE - 7  -- Last 7 days
GROUP BY session_id, user_name
ORDER BY session_activity_count DESC;

-- 9. Daily audit log volume
SELECT 
  TO_CHAR(event_timestamp, 'YYYY-MM-DD') as date,
  COUNT(*) as daily_log_count,
  SUM(CASE WHEN success_flag = 'Y' THEN 1 ELSE 0 END) as successful_operations,
  SUM(CASE WHEN success_flag = 'N' THEN 1 ELSE 0 END) as failed_operations
FROM AUDIT_LOG
WHERE event_timestamp >= SYSDATE - 30  -- Last 30 days
GROUP BY TO_CHAR(event_timestamp, 'YYYY-MM-DD')
ORDER BY date;

-- 10. Audit log growth trend
SELECT 
  TO_CHAR(event_timestamp, 'YYYY-MM') as month,
  COUNT(*) as monthly_log_count
FROM AUDIT_LOG
WHERE event_timestamp >= ADD_MONTHS(SYSDATE, -12)  -- Last 12 months
GROUP BY TO_CHAR(event_timestamp, 'YYYY-MM')
ORDER BY month;

-- 11. Most active hours
SELECT 
  TO_CHAR(event_timestamp, 'HH24') as hour,
  COUNT(*) as hourly_activity
FROM AUDIT_LOG
WHERE event_timestamp >= SYSDATE - 30  -- Last 30 days
GROUP BY TO_CHAR(event_timestamp, 'HH24')
ORDER BY hourly_activity DESC;

-- 12. Weekend vs Weekday activity
SELECT 
  CASE 
    WHEN TO_NUMBER(TO_CHAR(event_timestamp, 'D')) IN (1, 7) THEN 'Weekend'
    ELSE 'Weekday'
  END as day_type,
  COUNT(*) as activity_count
FROM AUDIT_LOG
WHERE event_timestamp >= SYSDATE - 30  -- Last 30 days
GROUP BY 
  CASE 
    WHEN TO_NUMBER(TO_CHAR(event_timestamp, 'D')) IN (1, 7) THEN 'Weekend'
    ELSE 'Weekday'
  END
ORDER BY activity_count DESC;