-- PL/SQL Package for Customer Loyalty Points & Rewards Automation System
-- This script creates a package that groups related procedures and functions

-- Connect as loyalty_owner user
-- CONN loyalty_owner/frank@localhost:1521/tue_26652_frank_loyalty_db

-- Package Specification
CREATE OR REPLACE PACKAGE LOYALTY_PKG AS
  -- Procedure declarations
  PROCEDURE ADD_LOYALTY_POINTS (
    p_customer_id IN NUMBER,
    p_purchase_id IN NUMBER,
    p_points IN NUMBER,
    p_result_message OUT VARCHAR2
  );
  
  PROCEDURE REDEEM_REWARD (
    p_customer_id IN NUMBER,
    p_reward_id IN NUMBER,
    p_redemption_message OUT VARCHAR2
  );
  
  PROCEDURE ADD_PROMOTIONAL_BONUS (
    p_customer_id IN NUMBER,
    p_bonus_points IN NUMBER,
    p_promotion_name IN VARCHAR2,
    p_bonus_message OUT VARCHAR2
  );
  
  PROCEDURE EXPIRE_LOYALTY_POINTS (
    p_cutoff_date IN DATE DEFAULT SYSDATE,
    p_expired_count OUT NUMBER,
    p_expiration_message OUT VARCHAR2
  );
  
  -- Function declarations
  FUNCTION CALCULATE_POINTS (
    p_purchase_amount IN NUMBER
  ) RETURN NUMBER;
  
  FUNCTION GET_CUSTOMER_POINTS (
    p_customer_id IN NUMBER
  ) RETURN NUMBER;
  
  FUNCTION CAN_REDEEM_REWARD (
    p_customer_id IN NUMBER,
    p_reward_id IN NUMBER
  ) RETURN VARCHAR2;
  
  FUNCTION GET_ELIGIBLE_REWARDS (
    p_customer_id IN NUMBER
  ) RETURN VARCHAR2;
  
  FUNCTION IS_HOLIDAY (
    p_check_date IN DATE
  ) RETURN VARCHAR2;
  
  -- Additional utility functions
  FUNCTION GET_CUSTOMER_TIER (
    p_customer_id IN NUMBER
  ) RETURN VARCHAR2;
  
  FUNCTION GET_TOTAL_PURCHASES (
    p_customer_id IN NUMBER
  ) RETURN NUMBER;
  
END LOYALTY_PKG;
/

-- Package Body
CREATE OR REPLACE PACKAGE BODY LOYALTY_PKG AS
  
  -- Procedure to add loyalty points after a purchase
  PROCEDURE ADD_LOYALTY_POINTS (
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
  
  -- Procedure to redeem rewards
  PROCEDURE REDEEM_REWARD (
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
  
  -- Procedure to add promotional bonus points
  PROCEDURE ADD_PROMOTIONAL_BONUS (
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
  
  -- Procedure to expire loyalty points
  PROCEDURE EXPIRE_LOYALTY_POINTS (
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
  
  -- Function to calculate points for a purchase amount
  FUNCTION CALCULATE_POINTS (
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
  
  -- Function to get customer's current point balance
  FUNCTION GET_CUSTOMER_POINTS (
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
  
  -- Function to validate if customer can redeem a reward
  FUNCTION CAN_REDEEM_REWARD (
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
  
  -- Function to get customer's reward eligibility
  FUNCTION GET_ELIGIBLE_REWARDS (
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
  
  -- Function to check if a date is a holiday
  FUNCTION IS_HOLIDAY (
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
  
  -- Function to get customer tier based on points
  FUNCTION GET_CUSTOMER_TIER (
    p_customer_id IN NUMBER
  ) RETURN VARCHAR2 AS
    v_total_points NUMBER;
  BEGIN
    v_total_points := GET_CUSTOMER_POINTS(p_customer_id);
    
    IF v_total_points >= 10000 THEN
      RETURN 'PLATINUM';
    ELSIF v_total_points >= 5000 THEN
      RETURN 'GOLD';
    ELSIF v_total_points >= 1000 THEN
      RETURN 'SILVER';
    ELSIF v_total_points >= 100 THEN
      RETURN 'BRONZE';
    ELSE
      RETURN 'NEW';
    END IF;
  END GET_CUSTOMER_TIER;
  
  -- Function to get total purchases for a customer
  FUNCTION GET_TOTAL_PURCHASES (
    p_customer_id IN NUMBER
  ) RETURN NUMBER AS
    v_total_purchases NUMBER;
  BEGIN
    SELECT NVL(SUM(amount), 0) INTO v_total_purchases
    FROM PURCHASES
    WHERE customer_id = p_customer_id;
    
    RETURN v_total_purchases;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN 0;
    WHEN OTHERS THEN
      RETURN -1;
  END GET_TOTAL_PURCHASES;
  
END LOYALTY_PKG;
/

-- Display package information
SELECT object_name, object_type, status 
FROM user_objects 
WHERE object_type IN ('PACKAGE', 'PACKAGE BODY')
AND object_name = 'LOYALTY_PKG'
ORDER BY object_type, object_name;