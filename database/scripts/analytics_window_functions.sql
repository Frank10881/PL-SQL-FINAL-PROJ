-- Analytics Window Functions for Customer Loyalty Points & Rewards Automation System
-- This script creates queries using window functions for business intelligence

-- Connect as loyalty_owner user
-- CONN loyalty_owner/frank@localhost:1521/tue_26652_frank_loyalty_db

-- 1. Customer ranking by total points (using RANK)
PROMPT === Customer Ranking by Total Points ===
SELECT 
  customer_id,
  full_name,
  total_points,
  RANK() OVER (ORDER BY total_points DESC) as rank_by_points,
  DENSE_RANK() OVER (ORDER BY total_points DESC) as dense_rank_by_points
FROM (
  SELECT 
    c.customer_id,
    c.full_name,
    NVL(SUM(lp.points), 0) as total_points
  FROM CUSTOMERS c
  LEFT JOIN LOYALTY_POINTS lp ON c.customer_id = lp.customer_id AND lp.status = 'ACTIVE'
  GROUP BY c.customer_id, c.full_name
)
ORDER BY total_points DESC
FETCH FIRST 20 ROWS ONLY;

-- 2. Customer purchase trends using LAG and LEAD
PROMPT === Customer Purchase Trends ===
WITH customer_monthly_purchases AS (
  SELECT 
    c.customer_id,
    c.full_name,
    TRUNC(p.purchase_date, 'MM') as purchase_month,
    SUM(p.amount) as monthly_amount,
    COUNT(p.purchase_id) as monthly_count
  FROM CUSTOMERS c
  JOIN PURCHASES p ON c.customer_id = p.customer_id
  GROUP BY c.customer_id, c.full_name, TRUNC(p.purchase_date, 'MM')
)
SELECT 
  customer_id,
  full_name,
  purchase_month,
  monthly_amount,
  LAG(monthly_amount) OVER (PARTITION BY customer_id ORDER BY purchase_month) as prev_month_amount,
  LEAD(monthly_amount) OVER (PARTITION BY customer_id ORDER BY purchase_month) as next_month_amount,
  monthly_amount - LAG(monthly_amount) OVER (PARTITION BY customer_id ORDER BY purchase_month) as month_over_month_change
FROM customer_monthly_purchases
ORDER BY customer_id, purchase_month
FETCH FIRST 30 ROWS ONLY;

-- 3. Running totals and moving averages for purchases
PROMPT === Running Totals and Moving Averages ===
WITH daily_purchases AS (
  SELECT 
    TRUNC(purchase_date) as purchase_day,
    SUM(amount) as daily_amount,
    COUNT(purchase_id) as daily_count
  FROM PURCHASES
  GROUP BY TRUNC(purchase_date)
)
SELECT 
  purchase_day,
  daily_amount,
  SUM(daily_amount) OVER (ORDER BY purchase_day ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as running_total,
  AVG(daily_amount) OVER (ORDER BY purchase_day ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) as seven_day_avg,
  AVG(daily_amount) OVER (ORDER BY purchase_day ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) as thirty_day_avg
FROM daily_purchases
ORDER BY purchase_day
FETCH FIRST 50 ROWS ONLY;

-- 4. Percentile analysis of customer spending
PROMPT === Customer Spending Percentiles ===
SELECT 
  customer_id,
  full_name,
  total_spent,
  PERCENT_RANK() OVER (ORDER BY total_spent) as percentile_rank,
  CUME_DIST() OVER (ORDER BY total_spent) as cumulative_distribution,
  NTILE(10) OVER (ORDER BY total_spent) as decile
FROM (
  SELECT 
    c.customer_id,
    c.full_name,
    NVL(SUM(p.amount), 0) as total_spent
  FROM CUSTOMERS c
  LEFT JOIN PURCHASES p ON c.customer_id = p.customer_id
  GROUP BY c.customer_id, c.full_name
)
ORDER BY total_spent DESC
FETCH FIRST 30 ROWS ONLY;

-- 5. First and last purchase analysis by customer
PROMPT === First and Last Purchase Analysis ===
SELECT 
  customer_id,
  full_name,
  first_purchase_date,
  last_purchase_date,
  last_purchase_date - first_purchase_date as customer_lifetime_days,
  total_purchases,
  total_spent
FROM (
  SELECT 
    c.customer_id,
    c.full_name,
    FIRST_VALUE(p.purchase_date) OVER (PARTITION BY c.customer_id ORDER BY p.purchase_date) as first_purchase_date,
    LAST_VALUE(p.purchase_date) OVER (PARTITION BY c.customer_id ORDER BY p.purchase_date ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as last_purchase_date,
    COUNT(p.purchase_id) OVER (PARTITION BY c.customer_id) as total_purchases,
    SUM(p.amount) OVER (PARTITION BY c.customer_id) as total_spent
  FROM CUSTOMERS c
  JOIN PURCHASES p ON c.customer_id = p.customer_id
)
GROUP BY customer_id, full_name, first_purchase_date, last_purchase_date, total_purchases, total_spent
ORDER BY customer_lifetime_days DESC
FETCH FIRST 25 ROWS ONLY;

-- 6. Points earning trends with window functions
PROMPT === Points Earning Trends ===
WITH customer_points_timeline AS (
  SELECT 
    lp.customer_id,
    c.full_name,
    lp.earned_date,
    lp.points,
    SUM(lp.points) OVER (PARTITION BY lp.customer_id ORDER BY lp.earned_date) as cumulative_points
  FROM LOYALTY_POINTS lp
  JOIN CUSTOMERS c ON lp.customer_id = c.customer_id
  WHERE lp.status IN ('ACTIVE', 'REDEEMED')
)
SELECT 
  customer_id,
  full_name,
  earned_date,
  points,
  cumulative_points,
  LAG(cumulative_points) OVER (PARTITION BY customer_id ORDER BY earned_date) as previous_cumulative,
  cumulative_points - LAG(cumulative_points) OVER (PARTITION BY customer_id ORDER BY earned_date) as points_since_last
FROM customer_points_timeline
ORDER BY customer_id, earned_date
FETCH FIRST 40 ROWS ONLY;

-- 7. Reward redemption patterns
PROMPT === Reward Redemption Patterns ===
WITH redemption_analysis AS (
  SELECT 
    r.reward_id,
    rw.reward_name,
    r.redemption_date,
    r.points_deducted,
    ROW_NUMBER() OVER (PARTITION BY r.reward_id ORDER BY r.redemption_date) as redemption_sequence,
    COUNT(*) OVER (PARTITION BY r.reward_id) as total_redemptions,
    SUM(r.points_deducted) OVER (PARTITION BY r.reward_id ORDER BY r.redemption_date) as cumulative_points_redeemed
  FROM REDEMPTIONS r
  JOIN REWARDS rw ON r.reward_id = rw.reward_id
)
SELECT 
  reward_id,
  reward_name,
  redemption_date,
  points_deducted,
  redemption_sequence,
  total_redemptions,
  cumulative_points_redeemed
FROM redemption_analysis
ORDER BY total_redemptions DESC, redemption_sequence
FETCH FIRST 30 ROWS ONLY;

-- 8. Customer segmentation using window functions
PROMPT === Customer Segmentation Analysis ===
WITH customer_metrics AS (
  SELECT 
    c.customer_id,
    c.full_name,
    COUNT(p.purchase_id) as total_purchases,
    NVL(SUM(p.amount), 0) as total_spent,
    NVL(SUM(lp.points), 0) as total_points,
    COUNT(r.redemption_id) as total_redemptions
  FROM CUSTOMERS c
  LEFT JOIN PURCHASES p ON c.customer_id = p.customer_id
  LEFT JOIN LOYALTY_POINTS lp ON c.customer_id = lp.customer_id AND lp.status = 'ACTIVE'
  LEFT JOIN REDEMPTIONS r ON c.customer_id = r.customer_id
  GROUP BY c.customer_id, c.full_name
),
customer_percentiles AS (
  SELECT 
    customer_id,
    full_name,
    total_purchases,
    total_spent,
    total_points,
    total_redemptions,
    PERCENT_RANK() OVER (ORDER BY total_spent) as spending_percentile,
    PERCENT_RANK() OVER (ORDER BY total_points) as points_percentile,
    PERCENT_RANK() OVER (ORDER BY total_redemptions) as redemption_percentile
  FROM customer_metrics
)
SELECT 
  customer_id,
  full_name,
  total_spent,
  total_points,
  ROUND(spending_percentile * 100, 2) as spending_percentile,
  ROUND(points_percentile * 100, 2) as points_percentile,
  CASE 
    WHEN spending_percentile >= 0.8 THEN 'High Spender'
    WHEN spending_percentile >= 0.5 THEN 'Medium Spender'
    ELSE 'Low Spender'
  END as spending_segment,
  CASE 
    WHEN points_percentile >= 0.8 THEN 'High Earner'
    WHEN points_percentile >= 0.5 THEN 'Medium Earner'
    ELSE 'Low Earner'
  END as points_segment
FROM customer_percentiles
ORDER BY total_spent DESC
FETCH FIRST 25 ROWS ONLY;