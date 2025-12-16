# KPI Definitions

## Project Title
Customer Loyalty Points & Rewards Automation System

## Student Information
* **Name:** Frank Nasiimwe
* **Student ID:** 26652
* **Course:** Database Development with PL/SQL (INSY 8311)
* **Institution:** Adventist University of Central Africa (AUCA)

## Overview
This document defines the key performance indicators (KPIs) used to measure the success and effectiveness of the Customer Loyalty Points & Rewards Automation System. Each KPI includes a detailed definition, calculation method, target values, and business significance.

## Customer Engagement KPIs

### 1. Active Customer Rate

#### Definition
Percentage of customers who have made purchases in the last 30 days.

#### Formula
(Number of customers with purchases in last 30 days / Total number of loyalty members) × 100

#### Target Value
75% or higher

#### Business Significance
Indicates the level of ongoing engagement with the loyalty program. A declining rate may signal issues with program relevance or customer satisfaction.

#### Calculation Query
```sql
SELECT 
  ROUND((COUNT(DISTINCT CASE WHEN last_purchase_date >= SYSDATE - 30 THEN customer_id END) 
  / COUNT(DISTINCT customer_id)) * 100, 2) AS active_customer_rate
FROM CUSTOMERS c
LEFT JOIN (
  SELECT customer_id, MAX(purchase_date) AS last_purchase_date
  FROM PURCHASES
  GROUP BY customer_id
) p ON c.customer_id = p.customer_id;
```

### 2. Customer Retention Rate

#### Definition
Percentage of customers who continue to make purchases over a specified period.

#### Formula
((Number of customers at end of period - Number of new customers during period) / Number of customers at start of period) × 100

#### Target Value
80% or higher annually

#### Business Significance
Measures customer loyalty and program effectiveness in maintaining long-term relationships.

#### Calculation Query
```sql
WITH customer_periods AS (
  SELECT 
    customer_id,
    CASE WHEN MIN(purchase_date) >= ADD_MONTHS(SYSDATE, -12) THEN 'new' ELSE 'existing' END AS customer_type
  FROM PURCHASES
  WHERE purchase_date BETWEEN ADD_MONTHS(SYSDATE, -12) AND SYSDATE
  GROUP BY customer_id
)
SELECT 
  ROUND(((COUNT(DISTINCT customer_id) - COUNT(DISTINCT CASE WHEN customer_type = 'new' THEN customer_id END))
  / (SELECT COUNT(DISTINCT customer_id) FROM PURCHASES WHERE purchase_date < ADD_MONTHS(SYSDATE, -12))) * 100, 2) 
  AS retention_rate
FROM customer_periods;
```

### 3. Average Customer Lifetime Value (CLV)

#### Definition
Total revenue generated per customer over their relationship with the business.

#### Formula
Average purchase value × Purchase frequency × Customer lifespan

#### Target Value
$1,500 or higher

#### Business Significance
Determines the long-term value of each customer and informs marketing spend decisions.

#### Calculation Query
```sql
WITH customer_metrics AS (
  SELECT 
    c.customer_id,
    COUNT(p.purchase_id) AS total_purchases,
    SUM(p.amount) AS total_spent,
    MAX(p.purchase_date) - MIN(p.purchase_date) AS customer_lifespan_days
  FROM CUSTOMERS c
  JOIN PURCHASES p ON c.customer_id = p.customer_id
  GROUP BY c.customer_id
)
SELECT 
  ROUND(AVG(total_spent), 2) AS avg_lifetime_value,
  ROUND(AVG(total_spent / total_purchases), 2) AS avg_purchase_value,
  ROUND(AVG(total_purchases / (customer_lifespan_days / 365)), 2) AS purchase_frequency_per_year
FROM customer_metrics;
```

### 4. Customer Acquisition Cost (CAC)

#### Definition
Average cost to acquire a new loyalty program member.

#### Formula
Total marketing and enrollment costs / Number of new customers acquired

#### Target Value
Less than 15% of first-year customer value

#### Business Significance
Measures the efficiency of customer acquisition efforts and informs budget allocation.

#### Calculation Query
```sql
-- Note: This requires marketing cost data which would typically be in a separate table
-- For demonstration purposes, we'll show the structure
SELECT 
  ROUND(SUM(marketing_costs) / COUNT(DISTINCT customer_id), 2) AS customer_acquisition_cost
FROM MARKETING_CAMPAIGNS mc
JOIN CUSTOMERS c ON mc.campaign_id = c.acquisition_campaign_id
WHERE c.enrollment_date BETWEEN :start_date AND :end_date;
```

## Loyalty Program Performance KPIs

### 1. Points Issued Rate

#### Definition
Number of loyalty points issued per day/week/month.

#### Formula
Total points issued in period / Number of days in period

#### Target Value
50,000 points per day average

#### Business Significance
Measures program activity and customer engagement with the point accumulation mechanism.

#### Calculation Query
```sql
SELECT 
  ROUND(SUM(points_added) / COUNT(DISTINCT TRUNC(transaction_date)), 2) AS avg_points_per_day,
  SUM(points_added) AS total_points_issued
FROM LOYALTY_POINTS
WHERE transaction_date >= ADD_MONTHS(SYSDATE, -1);
```

### 2. Points Redemption Rate

#### Definition
Percentage of issued points that are actually redeemed.

#### Formula
(Number of points redeemed / Number of points issued) × 100

#### Target Value
65% or higher

#### Business Significance
Indicates the attractiveness and usability of rewards offered to customers.

#### Calculation Query
```sql
SELECT 
  ROUND((SUM(CASE WHEN transaction_type = 'REDEMPTION' THEN ABS(points_amount) ELSE 0 END) 
  / SUM(CASE WHEN transaction_type = 'EARNED' THEN points_amount ELSE 0 END)) * 100, 2) AS redemption_rate
FROM LOYALTY_POINTS;
```

### 3. Reward Redemption Frequency

#### Definition
Average number of rewards redeemed per active customer.

#### Formula
Total number of rewards redeemed / Number of active customers

#### Target Value
2.5 rewards per active customer annually

#### Business Significance
Measures how actively customers are engaging with the reward system.

#### Calculation Query
```sql
SELECT 
  ROUND(COUNT(redemption_id) / COUNT(DISTINCT customer_id), 2) AS avg_redemptions_per_customer
FROM REDEMPTIONS r
JOIN CUSTOMERS c ON r.customer_id = c.customer_id
WHERE r.redemption_date >= ADD_MONTHS(SYSDATE, -12)
AND EXISTS (
  SELECT 1 FROM PURCHASES p 
  WHERE p.customer_id = c.customer_id 
  AND p.purchase_date >= ADD_MONTHS(SYSDATE, -12)
);
```

### 4. Points Expiration Rate

#### Definition
Percentage of points that expire without being redeemed.

#### Formula
(Number of expired points / Total points issued) × 100

#### Target Value
Less than 10%

#### Business Significance
Measures program effectiveness and identifies potential customer dissatisfaction.

#### Calculation Query
```sql
SELECT 
  ROUND((SUM(CASE WHEN expiration_date < SYSDATE AND balance = 0 THEN initial_points ELSE 0 END)
  / SUM(initial_points)) * 100, 2) AS points_expiration_rate
FROM LOYALTY_POINTS lp
WHERE lp.transaction_date >= ADD_MONTHS(SYSDATE, -18);  -- Points that had time to expire
```

## Revenue and Sales KPIs

### 1. Loyalty Program Revenue Impact

#### Definition
Increase in sales attributed to the loyalty program.

#### Formula
Revenue from loyalty members - Revenue from similar non-members

#### Target Value
15% increase in revenue from loyalty members

#### Business Significance
Quantifies the direct financial benefit of the loyalty program.

#### Calculation Query
```sql
WITH loyalty_revenue AS (
  SELECT 
    SUM(p.amount) AS total_revenue,
    SUM(CASE WHEN l.customer_id IS NOT NULL THEN p.amount ELSE 0 END) AS loyalty_revenue,
    SUM(CASE WHEN l.customer_id IS NULL THEN p.amount ELSE 0 END) AS non_loyalty_revenue
  FROM PURCHASES p
  LEFT JOIN LOYALTY_POINTS l ON p.customer_id = l.customer_id
  WHERE p.purchase_date >= ADD_MONTHS(SYSDATE, -12)
)
SELECT 
  ROUND(loyalty_revenue, 2) AS loyalty_revenue,
  ROUND(non_loyalty_revenue, 2) AS non_loyalty_revenue,
  ROUND(((loyalty_revenue / NULLIF(non_loyalty_revenue, 0)) - 1) * 100, 2) AS revenue_increase_pct
FROM loyalty_revenue;
```

### 2. Average Purchase Value

#### Definition
Average transaction amount for loyalty program members vs. non-members.

#### Formula
Total purchase amount / Number of purchases

#### Target Value
10% higher for loyalty members

#### Business Significance
Measures whether loyalty program members spend more per transaction.

#### Calculation Query
```sql
SELECT 
  'Loyalty Members' AS customer_group,
  ROUND(AVG(amount), 2) AS avg_purchase_value,
  COUNT(purchase_id) AS total_purchases
FROM PURCHASES p
WHERE EXISTS (
  SELECT 1 FROM LOYALTY_POINTS lp 
  WHERE lp.customer_id = p.customer_id
)
UNION ALL
SELECT 
  'Non-Members' AS customer_group,
  ROUND(AVG(amount), 2) AS avg_purchase_value,
  COUNT(purchase_id) AS total_purchases
FROM PURCHASES p
WHERE NOT EXISTS (
  SELECT 1 FROM LOYALTY_POINTS lp 
  WHERE lp.customer_id = p.customer_id
);
```

### 3. Purchase Frequency

#### Definition
How often loyalty members make purchases compared to baseline.

#### Formula
Number of purchases / Number of unique customers

#### Target Value
2.0 purchases per member per month

#### Business Significance
Indicates customer engagement and program effectiveness in driving repeat business.

#### Calculation Query
```sql
SELECT 
  ROUND(COUNT(purchase_id) / COUNT(DISTINCT customer_id), 2) AS avg_purchase_frequency
FROM PURCHASES
WHERE purchase_date >= ADD_MONTHS(SYSDATE, -3)
AND customer_id IN (
  SELECT DISTINCT customer_id FROM LOYALTY_POINTS
);
```

### 4. Seasonal Sales Trends

#### Definition
Sales patterns correlated with loyalty program activities.

#### Formula
Monthly revenue comparison year-over-year

#### Target Value
Identify and capitalize on seasonal opportunities

#### Business Significance
Enables targeted marketing and inventory planning based on predictable demand patterns.

#### Calculation Query
```sql
SELECT 
  TO_CHAR(purchase_date, 'YYYY-MM') AS month,
  SUM(amount) AS monthly_revenue,
  LAG(SUM(amount)) OVER (ORDER BY TO_CHAR(purchase_date, 'YYYY-MM')) AS prev_year_revenue,
  ROUND(((SUM(amount) / LAG(SUM(amount)) OVER (ORDER BY TO_CHAR(purchase_date, 'YYYY-MM'))) - 1) * 100, 2) AS growth_rate
FROM PURCHASES
WHERE purchase_date >= ADD_MONTHS(SYSDATE, -24)
GROUP BY TO_CHAR(purchase_date, 'YYYY-MM')
ORDER BY month;
```

## Reward Program Effectiveness KPIs

### 1. Reward Utilization Rate

#### Definition
Percentage of available rewards that are being claimed.

#### Formula
(Number of rewards claimed / Number of rewards offered) × 100

#### Target Value
70% or higher

#### Business Significance
Measures the appeal and relevance of reward offerings.

#### Calculation Query
```sql
-- This would require a REWARDS_CATALOG table to track all possible rewards
-- For demonstration purposes:
SELECT 
  ROUND((COUNT(CASE WHEN status = 'CLAIMED' THEN 1 END) 
  / COUNT(*)) * 100, 2) AS reward_utilization_rate
FROM REWARDS;
```

### 2. Top Performing Rewards

#### Definition
Ranking of rewards by popularity and redemption rate.

#### Formula
Number of redemptions per reward type

#### Target Value
Maintain diverse portfolio with multiple popular options

#### Business Significance
Guides reward optimization and future reward development.

#### Calculation Query
```sql
SELECT 
  reward_type,
  COUNT(redemption_id) AS redemption_count,
  ROUND(AVG(points_required), 0) AS avg_points_required
FROM REDEMPTIONS r
JOIN REWARDS rw ON r.reward_id = rw.reward_id
GROUP BY reward_type
ORDER BY redemption_count DESC;
```

### 3. Cost Per Reward Claimed

#### Definition
Average cost to the business for each redeemed reward.

#### Formula
Total reward fulfillment costs / Number of rewards claimed

#### Target Value
Less than $5 per reward

#### Business Significance
Ensures reward program profitability and sustainability.

#### Calculation Query
```sql
SELECT 
  ROUND(SUM(reward_cost) / COUNT(redemption_id), 2) AS avg_cost_per_reward
FROM REDEMPTIONS r
JOIN REWARDS rw ON r.reward_id = rw.reward_id
WHERE r.redemption_status = 'COMPLETED';
```

### 4. Reward Category Performance

#### Definition
Performance breakdown by reward type (discounts, free items, experiences).

#### Formula
Revenue impact and redemption rates by category

#### Target Value
Balanced performance across categories

#### Business Significance
Optimizes reward mix to maximize customer satisfaction and business goals.

#### Calculation Query
```sql
SELECT 
  reward_category,
  COUNT(redemption_id) AS redemptions,
  ROUND(AVG(points_required), 0) AS avg_points_needed,
  ROUND(COUNT(redemption_id) * 100.0 / SUM(COUNT(redemption_id)) OVER(), 2) AS percentage_of_total
FROM REDEMPTIONS r
JOIN REWARDS rw ON r.reward_id = rw.reward_id
GROUP BY reward_category
ORDER BY redemptions DESC;
```

## KPI Monitoring and Reporting

### Frequency of Measurement
* Real-time: System performance metrics
* Daily: Transaction volumes and error rates
* Weekly: Customer engagement and program utilization
* Monthly: Financial impact and revenue metrics
* Quarterly: Strategic performance indicators
* Annually: Comprehensive program evaluation

### Alert Thresholds
* Critical: Issues requiring immediate attention (system downtime, security breaches)
* Warning: Trends indicating potential problems (declining engagement, increasing costs)
* Informational: Regular performance updates (monthly reports, quarterly reviews)

### Stakeholder Communication
* Executives: Monthly executive summaries with key metrics
* Marketing: Weekly customer engagement reports
* Operations: Daily system performance dashboards
* Finance: Monthly financial impact analyses
* IT: Real-time system monitoring alerts

### Continuous Improvement
* Quarterly KPI review and adjustment
* Annual target reassessment based on business goals
* Regular feedback collection from stakeholders
* Benchmarking against industry standards