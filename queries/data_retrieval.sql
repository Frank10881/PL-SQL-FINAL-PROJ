-- Data Validation Script for Customer Loyalty Points & Rewards Automation System
-- This script validates 100-500+ rows per main table as required

-- Connect as loyalty_owner user
-- CONN loyalty_owner/frank@localhost:1521/tue_26652_frank_loyalty_db

-- 1. Basic Retrieval Queries (SELECT *)
PROMPT === BASIC RETRIEVAL QUERIES ===
SELECT 'Total Customers:' as METRIC, COUNT(*) as COUNT FROM CUSTOMERS;
SELECT 'Total Purchases:' as METRIC, COUNT(*) as COUNT FROM PURCHASES;
SELECT 'Total Loyalty Points:' as METRIC, COUNT(*) as COUNT FROM LOYALTY_POINTS;
SELECT 'Total Rewards:' as METRIC, COUNT(*) as COUNT FROM REWARDS;
SELECT 'Total Redemptions:' as METRIC, COUNT(*) as COUNT FROM REDEMPTIONS;

-- Show sample rows from each table
PROMPT === SAMPLE DATA FROM EACH TABLE ===
SELECT * FROM CUSTOMERS WHERE ROWNUM <= 10;
SELECT * FROM PURCHASES WHERE ROWNUM <= 10;
SELECT * FROM LOYALTY_POINTS WHERE ROWNUM <= 10;
SELECT * FROM REWARDS WHERE ROWNUM <= 10;
SELECT * FROM REDEMPTIONS WHERE ROWNUM <= 10;

-- 2. Join Queries
PROMPT === JOIN QUERIES ===

-- Customer purchase history (top 20)
PROMPT Top 20 customer purchase history:
SELECT c.full_name, p.purchase_date, p.amount, p.store_location
FROM CUSTOMERS c
JOIN PURCHASES p ON c.customer_id = p.customer_id
ORDER BY p.purchase_date DESC
FETCH FIRST 20 ROWS ONLY;

-- Customer point balances (top 20)
PROMPT Top 20 customer point balances:
SELECT c.full_name, 
       SUM(lp.points) AS total_points,
       COUNT(lp.point_id) AS point_entries
FROM CUSTOMERS c
LEFT JOIN LOYALTY_POINTS lp ON c.customer_id = lp.customer_id AND lp.status = 'ACTIVE'
GROUP BY c.customer_id, c.full_name
ORDER BY total_points DESC
FETCH FIRST 20 ROWS ONLY;

-- Redemption history (top 20)
PROMPT Top 20 redemption history:
SELECT c.full_name, r.reward_name, red.redemption_date, red.points_deducted
FROM REDEMPTIONS red
JOIN CUSTOMERS c ON red.customer_id = c.customer_id
JOIN REWARDS r ON red.reward_id = r.reward_id
ORDER BY red.redemption_date DESC
FETCH FIRST 20 ROWS ONLY;

-- Points earned per purchase (top 20)
PROMPT Top 20 points earned per purchase:
SELECT c.full_name, p.purchase_date, p.amount, lp.points
FROM LOYALTY_POINTS lp
JOIN CUSTOMERS c ON lp.customer_id = c.customer_id
JOIN PURCHASES p ON lp.purchase_id = p.purchase_id
ORDER BY p.purchase_date DESC
FETCH FIRST 20 ROWS ONLY;

-- 3. Aggregation Queries (GROUP BY)
PROMPT === AGGREGATION QUERIES ===

-- Total purchases by customer (top 20 spenders)
PROMPT Top 20 customers by total spending:
SELECT c.full_name, 
       COUNT(p.purchase_id) AS total_purchases,
       SUM(p.amount) AS total_spent,
       AVG(p.amount) AS avg_purchase_amount
FROM CUSTOMERS c
LEFT JOIN PURCHASES p ON c.customer_id = p.customer_id
GROUP BY c.customer_id, c.full_name
ORDER BY total_spent DESC NULLS LAST
FETCH FIRST 20 ROWS ONLY;

-- Points summary by status
PROMPT Points summary by status:
SELECT status, COUNT(*) AS count, SUM(points) AS total_points
FROM LOYALTY_POINTS
GROUP BY status
ORDER BY status;

-- Popular rewards (most redeemed - top 10)
PROMPT Top 10 popular rewards:
SELECT r.reward_name, COUNT(red.redemption_id) AS redemption_count
FROM REWARDS r
LEFT JOIN REDEMPTIONS red ON r.reward_id = red.reward_id
GROUP BY r.reward_id, r.reward_name
ORDER BY redemption_count DESC NULLS LAST
FETCH FIRST 10 ROWS ONLY;

-- Purchases by location
PROMPT Purchases by location:
SELECT store_location, COUNT(*) AS purchase_count, SUM(amount) AS total_amount
FROM PURCHASES
GROUP BY store_location
ORDER BY total_amount DESC;

-- Customer demographics by registration date periods
PROMPT Customer registration trends:
SELECT 
  CASE 
    WHEN registration_date >= TO_DATE('2025-01-01', 'YYYY-MM-DD') THEN '2025'
    WHEN registration_date >= TO_DATE('2024-01-01', 'YYYY-MM-DD') THEN '2024'
    ELSE 'Earlier'
  END AS registration_period,
  COUNT(*) AS customer_count
FROM CUSTOMERS
GROUP BY 
  CASE 
    WHEN registration_date >= TO_DATE('2025-01-01', 'YYYY-MM-DD') THEN '2025'
    WHEN registration_date >= TO_DATE('2024-01-01', 'YYYY-MM-DD') THEN '2024'
    ELSE 'Earlier'
  END
ORDER BY registration_period;

-- 4. Subqueries
PROMPT === SUBQUERY EXAMPLES ===

-- Customers with above average points (top 20)
PROMPT Top 20 customers with above average points:
SELECT c.full_name, SUM(lp.points) AS total_points
FROM CUSTOMERS c
JOIN LOYALTY_POINTS lp ON c.customer_id = lp.customer_id AND lp.status = 'ACTIVE'
GROUP BY c.customer_id, c.full_name
HAVING SUM(lp.points) > (
    SELECT AVG(customer_total) 
    FROM (
        SELECT SUM(lp2.points) AS customer_total
        FROM LOYALTY_POINTS lp2
        WHERE lp2.status = 'ACTIVE'
        GROUP BY lp2.customer_id
    )
)
ORDER BY total_points DESC
FETCH FIRST 20 ROWS ONLY;

-- Rewards that require more than average points
PROMPT Rewards requiring more than average points:
SELECT reward_name, points_required
FROM REWARDS
WHERE points_required > (
    SELECT AVG(points_required) 
    FROM REWARDS
)
AND availability_status = 'AVAILABLE'
ORDER BY points_required;

-- Customers who haven't made purchases in the last 60 days (top 20)
PROMPT Top 20 inactive customers (no purchases in last 60 days):
SELECT c.full_name, c.phone, 
       MAX(p.purchase_date) AS last_purchase_date
FROM CUSTOMERS c
LEFT JOIN PURCHASES p ON c.customer_id = p.customer_id
GROUP BY c.customer_id, c.full_name, c.phone
HAVING MAX(p.purchase_date) < SYSDATE - 60 OR MAX(p.purchase_date) IS NULL
ORDER BY last_purchase_date NULLS FIRST
FETCH FIRST 20 ROWS ONLY;

-- High-value customers (top 10% by spending)
PROMPT High-value customers (top 10% by spending):
WITH customer_spending AS (
  SELECT c.customer_id, c.full_name, SUM(p.amount) AS total_spent
  FROM CUSTOMERS c
  LEFT JOIN PURCHASES p ON c.customer_id = p.customer_id
  GROUP BY c.customer_id, c.full_name
),
percentiles AS (
  SELECT PERCENTILE_CONT(0.9) WITHIN GROUP (ORDER BY total_spent) AS spending_threshold
  FROM customer_spending
)
SELECT cs.full_name, cs.total_spent
FROM customer_spending cs
CROSS JOIN percentiles p
WHERE cs.total_spent >= p.spending_threshold
ORDER BY cs.total_spent DESC;

-- 5. Constraint Validation
PROMPT === CONSTRAINT VALIDATION ===

-- Check for duplicate phone numbers
PROMPT Checking for duplicate phone numbers:
SELECT phone, COUNT(*) as count
FROM CUSTOMERS
GROUP BY phone
HAVING COUNT(*) > 1;

-- Check for duplicate email addresses
PROMPT Checking for duplicate email addresses:
SELECT email, COUNT(*) as count
FROM CUSTOMERS
GROUP BY email
HAVING COUNT(*) > 1;

-- Check for negative purchase amounts
PROMPT Checking for negative purchase amounts:
SELECT COUNT(*) as negative_purchases
FROM PURCHASES
WHERE amount <= 0;

-- Check for negative points
PROMPT Checking for negative points:
SELECT COUNT(*) as negative_points
FROM LOYALTY_POINTS
WHERE points < 0;

-- Check for invalid point statuses
PROMPT Checking for invalid point statuses:
SELECT DISTINCT status
FROM LOYALTY_POINTS
WHERE status NOT IN ('ACTIVE', 'EXPIRED', 'REDEEMED');

-- Check for invalid reward statuses
PROMPT Checking for invalid reward statuses:
SELECT DISTINCT availability_status
FROM REWARDS
WHERE availability_status NOT IN ('AVAILABLE', 'UNAVAILABLE');

-- Check for future purchase dates
PROMPT Checking for future purchase dates:
SELECT COUNT(*) as future_purchases
FROM PURCHASES
WHERE purchase_date > SYSDATE;

-- Check for points with missing earned dates
PROMPT Checking for points with missing earned dates:
SELECT COUNT(*) as missing_earned_dates
FROM LOYALTY_POINTS
WHERE earned_date IS NULL;

-- 6. Referential Integrity Checks
PROMPT === REFERENTIAL INTEGRITY CHECKS ===

-- Check for orphaned loyalty points (customer_id not in CUSTOMERS)
PROMPT Checking for orphaned loyalty points:
SELECT COUNT(*) as orphaned_points
FROM LOYALTY_POINTS lp
WHERE NOT EXISTS (
    SELECT 1 FROM CUSTOMERS c WHERE c.customer_id = lp.customer_id
);

-- Check for purchases with invalid customer_id
PROMPT Checking for purchases with invalid customer_id:
SELECT COUNT(*) as invalid_purchases
FROM PURCHASES p
WHERE NOT EXISTS (
    SELECT 1 FROM CUSTOMERS c WHERE c.customer_id = p.customer_id
);

-- Check for redemptions with invalid customer_id or reward_id
PROMPT Checking for redemptions with invalid references:
SELECT COUNT(*) as invalid_redemptions
FROM REDEMPTIONS r
WHERE NOT EXISTS (
    SELECT 1 FROM CUSTOMERS c WHERE c.customer_id = r.customer_id
) OR NOT EXISTS (
    SELECT 1 FROM REWARDS rw WHERE rw.reward_id = r.reward_id
);

-- Check for loyalty points with invalid purchase_id
PROMPT Checking for loyalty points with invalid purchase references:
SELECT COUNT(*) as invalid_point_purchases
FROM LOYALTY_POINTS lp
WHERE lp.purchase_id IS NOT NULL
AND NOT EXISTS (
    SELECT 1 FROM PURCHASES p WHERE p.purchase_id = lp.purchase_id
);

-- 7. Business Rule Validation
PROMPT === BUSINESS RULE VALIDATION ===

-- Check for expired points that are still marked as ACTIVE
PROMPT Checking for expired points marked as ACTIVE:
SELECT COUNT(*) as misclassified_expired_points
FROM LOYALTY_POINTS
WHERE status = 'ACTIVE' AND expiry_date < SYSDATE;

-- Check for redeemed points that are still marked as ACTIVE
PROMPT Checking for redeemed points marked as ACTIVE:
SELECT COUNT(*) as misclassified_redeemed_points
FROM LOYALTY_POINTS lp
WHERE status = 'ACTIVE' 
AND EXISTS (
    SELECT 1 FROM REDEMPTIONS r WHERE r.customer_id = lp.customer_id
);

-- Check for unavailable rewards that have recent redemptions
PROMPT Checking for redemptions of unavailable rewards:
SELECT COUNT(*) as unavailable_reward_redemptions
FROM REDEMPTIONS r
JOIN REWARDS rw ON r.reward_id = rw.reward_id
WHERE rw.availability_status = 'UNAVAILABLE';

-- 8. Data Distribution Analysis
PROMPT === DATA DISTRIBUTION ANALYSIS ===

-- Purchase amount distribution
PROMPT Purchase amount distribution:
SELECT 
  CASE 
    WHEN amount < 50 THEN '< $50'
    WHEN amount < 100 THEN '$50-$99'
    WHEN amount < 200 THEN '$100-$199'
    WHEN amount < 500 THEN '$200-$499'
    ELSE '> $500'
  END AS amount_range,
  COUNT(*) AS frequency
FROM PURCHASES
GROUP BY 
  CASE 
    WHEN amount < 50 THEN '< $50'
    WHEN amount < 100 THEN '$50-$99'
    WHEN amount < 200 THEN '$100-$199'
    WHEN amount < 500 THEN '$200-$499'
    ELSE '> $500'
  END
ORDER BY MIN(amount);

-- Points distribution
PROMPT Points distribution:
SELECT 
  CASE 
    WHEN points < 100 THEN '< 100 pts'
    WHEN points < 500 THEN '100-499 pts'
    WHEN points < 1000 THEN '500-999 pts'
    WHEN points < 5000 THEN '1000-4999 pts'
    ELSE '> 5000 pts'
  END AS points_range,
  COUNT(*) AS frequency
FROM LOYALTY_POINTS
WHERE status = 'ACTIVE'
GROUP BY 
  CASE 
    WHEN points < 100 THEN '< 100 pts'
    WHEN points < 500 THEN '100-499 pts'
    WHEN points < 1000 THEN '500-999 pts'
    WHEN points < 5000 THEN '1000-4999 pts'
    ELSE '> 5000 pts'
  END
ORDER BY MIN(points);

PROMPT === VALIDATION COMPLETE ===