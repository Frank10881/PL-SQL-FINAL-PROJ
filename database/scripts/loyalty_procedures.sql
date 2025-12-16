-- PL/SQL Procedures for Customer Loyalty Points & Rewards Automation System
-- This script creates procedures for core loyalty program operations

-- Connect as loyalty_owner user
-- CONN loyalty_owner/frank@localhost:1521/tue_26652_frank_loyalty_db

-- 1. Procedure to add loyalty points after a purchase
CREATE OR REPLACE PROCEDURE ADD_LOYALTY_POINTS (
  p_customer_id IN NUMBER,
  p_purchase_id IN NUMBER,
  p_points IN NUMBER,
  p_result_message OUT VARCHAR2
) AS
  v_customer_exists NUMBER;
  v_purchase_exists NUMBER;
  v_points_id NUMBER;
BEGIN
  -- Validate customer exists
  SELECT COUNT(*) INTO v_customer_exists 
  FROM CUSTOMERS 
  WHERE customer_id = p_customer_id;
  
  IF v_customer_exists = 0 THEN
    p_result_message := 'Error: Customer ID ' || p_customer_id || ' does not exist';
    RETURN;
  END IF;
  
  -- Validate purchase exists
  SELECT COUNT(*) INTO v_purchase_exists 
  FROM PURCHASES 
  WHERE purchase_id = p_purchase_id;
  
  IF v_purchase_exists = 0 THEN
    p_result_message := 'Error: Purchase ID ' || p_purchase_id || ' does not exist';
    RETURN;
  END IF;
  
  -- Validate points value
  IF p_points <= 0 THEN
    p_result_message := 'Error: Points must be greater than zero';
    RETURN;
  END IF;
  
  -- Generate new point ID
  SELECT LOYALTY_POINTS_SEQ.NEXTVAL INTO v_points_id FROM DUAL;
  
  -- Insert loyalty points record
  INSERT INTO LOYALTY_POINTS (
    point_id,
    customer_id,
    points,
    earned_date,
    expiry_date,
    status,
    purchase_id
  ) VALUES (
    v_points_id,
    p_customer_id,
    p_points,
    SYSDATE,
    ADD_MONTHS(SYSDATE, 12), -- Points expire after 12 months
    'ACTIVE',
    p_purchase_id
  );
  
  COMMIT;
  p_result_message := 'Success: ' || p_points || ' points added for customer ID ' || p_customer_id;
  
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    p_result_message := 'Error: ' || SQLERRM;
END ADD_LOYALTY_POINTS;
/

-- 2. Procedure to redeem rewards
CREATE OR REPLACE PROCEDURE REDEEM_REWARD (
  p_customer_id IN NUMBER,
  p_reward_id IN NUMBER,
  p_redemption_message OUT VARCHAR2
) AS
  v_customer_exists NUMBER;
  v_reward_exists NUMBER;
  v_reward_points_req NUMBER;
  v_reward_name VARCHAR2(100);
  v_reward_status VARCHAR2(20);
  v_customer_points NUMBER;
  v_redemption_id NUMBER;
BEGIN
  -- Validate customer exists
  SELECT COUNT(*) INTO v_customer_exists 
  FROM CUSTOMERS 
  WHERE customer_id = p_customer_id;
  
  IF v_customer_exists = 0 THEN
    p_redemption_message := 'Error: Customer ID ' || p_customer_id || ' does not exist';
    RETURN;
  END IF;
  
  -- Validate reward exists
  SELECT COUNT(*), NVL(MAX(points_required), 0), NVL(MAX(reward_name), 'Unknown'), NVL(MAX(availability_status), 'UNAVAILABLE')
  INTO v_reward_exists, v_reward_points_req, v_reward_name, v_reward_status
  FROM REWARDS 
  WHERE reward_id = p_reward_id;
  
  IF v_reward_exists = 0 THEN
    p_redemption_message := 'Error: Reward ID ' || p_reward_id || ' does not exist';
    RETURN;
  END IF;
  
  -- Check if reward is available
  IF v_reward_status != 'AVAILABLE' THEN
    p_redemption_message := 'Error: Reward "' || v_reward_name || '" is not available for redemption';
    RETURN;
  END IF;
  
  -- Calculate customer's available points
  SELECT NVL(SUM(points), 0) INTO v_customer_points
  FROM LOYALTY_POINTS
  WHERE customer_id = p_customer_id AND status = 'ACTIVE';
  
  -- Check if customer has enough points
  IF v_customer_points < v_reward_points_req THEN
    p_redemption_message := 'Error: Insufficient points. Customer has ' || v_customer_points || 
                           ' points, but reward requires ' || v_reward_points_req || ' points';
    RETURN;
  END IF;
  
  -- Generate redemption ID
  SELECT REDEMPTIONS_SEQ.NEXTVAL INTO v_redemption_id FROM DUAL;
  
  -- Insert redemption record
  INSERT INTO REDEMPTIONS (
    redemption_id,
    customer_id,
    reward_id,
    redemption_date,
    points_deducted
  ) VALUES (
    v_redemption_id,
    p_customer_id,
    p_reward_id,
    SYSDATE,
    v_reward_points_req
  );
  
  -- Update loyalty points status to REDEEMED (simplified approach)
  UPDATE LOYALTY_POINTS
  SET status = 'REDEEMED'
  WHERE customer_id = p_customer_id 
  AND status = 'ACTIVE'
  AND point_id IN (
    SELECT point_id 
    FROM LOYALTY_POINTS
    WHERE customer_id = p_customer_id AND status = 'ACTIVE'
    ORDER BY earned_date
    FETCH FIRST 1 ROWS ONLY
  );
  
  COMMIT;
  p_redemption_message := 'Success: Reward "' || v_reward_name || '" redeemed for customer ID ' || p_customer_id;
  
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    p_redemption_message := 'Error: ' || SQLERRM;
END REDEEM_REWARD;
/

-- 3. Procedure to add promotional bonus points
CREATE OR REPLACE PROCEDURE ADD_PROMOTIONAL_BONUS (
  p_customer_id IN NUMBER,
  p_bonus_points IN NUMBER,
  p_promotion_name IN VARCHAR2,
  p_bonus_message OUT VARCHAR2
) AS
  v_customer_exists NUMBER;
  v_points_id NUMBER;
BEGIN
  -- Validate customer exists
  SELECT COUNT(*) INTO v_customer_exists 
  FROM CUSTOMERS 
  WHERE customer_id = p_customer_id;
  
  IF v_customer_exists = 0 THEN
    p_bonus_message := 'Error: Customer ID ' || p_customer_id || ' does not exist';
    RETURN;
  END IF;
  
  -- Validate bonus points value
  IF p_bonus_points <= 0 THEN
    p_bonus_message := 'Error: Bonus points must be greater than zero';
    RETURN;
  END IF;
  
  -- Generate new point ID
  SELECT LOYALTY_POINTS_SEQ.NEXTVAL INTO v_points_id FROM DUAL;
  
  -- Insert promotional bonus points record
  INSERT INTO LOYALTY_POINTS (
    point_id,
    customer_id,
    points,
    earned_date,
    expiry_date,
    status,
    purchase_id
  ) VALUES (
    v_points_id,
    p_customer_id,
    p_bonus_points,
    SYSDATE,
    ADD_MONTHS(SYSDATE, 6), -- Bonus points expire after 6 months
    'ACTIVE',
    NULL -- No specific purchase associated with promotional bonus
  );
  
  COMMIT;
  p_bonus_message := 'Success: ' || p_bonus_points || ' promotional bonus points added for customer ID ' || p_customer_id || 
                     ' for promotion: ' || p_promotion_name;
  
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    p_bonus_message := 'Error: ' || SQLERRM;
END ADD_PROMOTIONAL_BONUS;
/

-- 4. Procedure to expire loyalty points
CREATE OR REPLACE PROCEDURE EXPIRE_LOYALTY_POINTS (
  p_cutoff_date IN DATE DEFAULT SYSDATE,
  p_expired_count OUT NUMBER,
  p_expiration_message OUT VARCHAR2
) AS
BEGIN
  -- Update points that have expired
  UPDATE LOYALTY_POINTS
  SET status = 'EXPIRED'
  WHERE expiry_date < p_cutoff_date
  AND status = 'ACTIVE';
  
  p_expired_count := SQL%ROWCOUNT;
  COMMIT;
  
  p_expiration_message := 'Success: ' || p_expired_count || ' loyalty points have been expired';
  
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    p_expired_count := 0;
    p_expiration_message := 'Error: ' || SQLERRM;
END EXPIRE_LOYALTY_POINTS;
/

-- Display procedure information
SELECT object_name, object_type, status 
FROM user_objects 
WHERE object_type = 'PROCEDURE' 
AND object_name IN ('ADD_LOYALTY_POINTS', 'REDEEM_REWARD', 'ADD_PROMOTIONAL_BONUS', 'EXPIRE_LOYALTY_POINTS')
ORDER BY object_name;