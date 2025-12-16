-- PL/SQL Functions for Customer Loyalty Points & Rewards Automation System
-- This script creates functions for point calculations and validations

-- Connect as loyalty_owner user
-- CONN loyalty_owner/frank@localhost:1521/tue_26652_frank_loyalty_db

-- 1. Function to calculate points for a purchase amount
CREATE OR REPLACE FUNCTION CALCULATE_POINTS (
  p_purchase_amount IN NUMBER
) RETURN NUMBER AS
  v_points NUMBER;
BEGIN
  -- Simple calculation: 1 point per dollar spent
  -- Can be modified for more complex business rules
  v_points := FLOOR(p_purchase_amount);
  
  -- Minimum of 1 point for any purchase
  IF v_points < 1 THEN
    v_points := 1;
  END IF;
  
  RETURN v_points;
EXCEPTION
  WHEN OTHERS THEN
    RETURN 0;
END CALCULATE_POINTS;
/

-- 2. Function to get customer's current point balance
CREATE OR REPLACE FUNCTION GET_CUSTOMER_POINTS (
  p_customer_id IN NUMBER
) RETURN NUMBER AS
  v_total_points NUMBER;
BEGIN
  SELECT NVL(SUM(points), 0) INTO v_total_points
  FROM LOYALTY_POINTS
  WHERE customer_id = p_customer_id 
  AND status = 'ACTIVE';
  
  RETURN v_total_points;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN 0;
  WHEN OTHERS THEN
    RETURN -1; -- Error indicator
END GET_CUSTOMER_POINTS;
/

-- 3. Function to validate if customer can redeem a reward
CREATE OR REPLACE FUNCTION CAN_REDEEM_REWARD (
  p_customer_id IN NUMBER,
  p_reward_id IN NUMBER
) RETURN VARCHAR2 AS
  v_customer_points NUMBER;
  v_reward_points_req NUMBER;
  v_reward_status VARCHAR2(20);
BEGIN
  -- Get customer's available points
  v_customer_points := GET_CUSTOMER_POINTS(p_customer_id);
  
  -- Get reward requirements
  SELECT points_required, availability_status 
  INTO v_reward_points_req, v_reward_status
  FROM REWARDS 
  WHERE reward_id = p_reward_id;
  
  -- Check if customer has enough points and reward is available
  IF v_customer_points >= v_reward_points_req AND v_reward_status = 'AVAILABLE' THEN
    RETURN 'YES';
  ELSE
    RETURN 'NO';
  END IF;
  
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN 'NO';
  WHEN OTHERS THEN
    RETURN 'ERROR';
END CAN_REDEEM_REWARD;
/

-- 4. Function to get customer's reward eligibility
CREATE OR REPLACE FUNCTION GET_ELIGIBLE_REWARDS (
  p_customer_id IN NUMBER
) RETURN VARCHAR2 AS
  v_customer_points NUMBER;
  v_eligible_rewards VARCHAR2(4000);
  v_reward_list VARCHAR2(4000) := '';
  
  CURSOR eligible_rewards_cursor IS
    SELECT r.reward_name, r.points_required
    FROM REWARDS r
    WHERE r.availability_status = 'AVAILABLE'
    AND r.points_required <= (SELECT NVL(SUM(lp.points), 0) 
                              FROM LOYALTY_POINTS lp 
                              WHERE lp.customer_id = p_customer_id 
                              AND lp.status = 'ACTIVE')
    ORDER BY r.points_required;
BEGIN
  v_customer_points := GET_CUSTOMER_POINTS(p_customer_id);
  
  -- Build list of eligible rewards
  FOR reward_rec IN eligible_rewards_cursor LOOP
    IF LENGTH(v_reward_list) > 0 THEN
      v_reward_list := v_reward_list || ', ';
    END IF;
    v_reward_list := v_reward_list || reward_rec.reward_name || '(' || reward_rec.points_required || 'pts)';
  END LOOP;
  
  IF LENGTH(v_reward_list) = 0 THEN
    v_eligible_rewards := 'No eligible rewards';
  ELSE
    v_eligible_rewards := v_reward_list;
  END IF;
  
  RETURN v_eligible_rewards;
  
EXCEPTION
  WHEN OTHERS THEN
    RETURN 'Error retrieving eligible rewards';
END GET_ELIGIBLE_REWARDS;
/

-- 5. Function to check if a date is a holiday
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

-- Display function information
SELECT object_name, object_type, status 
FROM user_objects 
WHERE object_type = 'FUNCTION' 
AND object_name IN ('CALCULATE_POINTS', 'GET_CUSTOMER_POINTS', 'CAN_REDEEM_REWARD', 'GET_ELIGIBLE_REWARDS', 'IS_HOLIDAY')
ORDER BY object_name;