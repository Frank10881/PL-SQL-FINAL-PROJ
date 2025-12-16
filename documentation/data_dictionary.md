# Data Dictionary

## Project Title
Customer Loyalty Points & Rewards Automation System

## Student Information
* **Name:** Frank Nasiimwe
* **Student ID:** 26652
* **Course:** Database Development with PL/SQL (INSY 8311)
* **Institution:** Adventist University of Central Africa (AUCA)

## Overview
This document provides a comprehensive data dictionary for all tables, columns, constraints, and relationships in the Customer Loyalty Points & Rewards Automation System. It serves as a reference for developers, analysts, and database administrators working with the system.

## Table: CUSTOMERS

### Description
Stores information about customers enrolled in the loyalty program.

### Columns

| Column Name | Data Type | Nullable | Key | Default | Constraints | Description |
|-------------|-----------|----------|-----|---------|-------------|-------------|
| customer_id | NUMBER(10) | No | PK | Generated | PRIMARY KEY, NOT NULL | Unique identifier for each customer |
| full_name | VARCHAR2(100) | No |  |  | NOT NULL | Customer's full name |
| phone | VARCHAR2(20) | Yes |  |  | UNIQUE | Customer's phone number |
| email | VARCHAR2(100) | Yes |  |  | UNIQUE | Customer's email address |
| enrollment_date | DATE | No |  | SYSDATE | NOT NULL | Date customer joined the loyalty program |
| tier_level | VARCHAR2(20) | No |  | 'Bronze' | NOT NULL, CHECK IN ('Bronze','Silver','Gold','Platinum') | Customer's current loyalty tier |
| total_points | NUMBER(10) | No |  | 0 | NOT NULL, CHECK >= 0 | Total accumulated points |
| last_purchase_date | DATE | Yes |  |  |  | Date of customer's last purchase |

## Table: PURCHASES

### Description
Records all customer purchases that qualify for loyalty points.

### Columns

| Column Name | Data Type | Nullable | Key | Default | Constraints | Description |
|-------------|-----------|----------|-----|---------|-------------|-------------|
| purchase_id | NUMBER(12) | No | PK | Generated | PRIMARY KEY, NOT NULL | Unique identifier for each purchase |
| customer_id | NUMBER(10) | No | FK |  | FOREIGN KEY REFERENCES CUSTOMERS(customer_id), NOT NULL | Reference to the customer |
| purchase_date | DATE | No |  | SYSDATE | NOT NULL | Date and time of the purchase |
| amount | NUMBER(10,2) | No |  |  | NOT NULL, CHECK > 0 | Purchase amount in local currency |
| store_location | VARCHAR2(100) | Yes |  |  |  | Location where purchase was made |
| receipt_number | VARCHAR2(50) | Yes |  |  | UNIQUE | Store receipt number |
| points_awarded | NUMBER(8) | No |  | 0 | NOT NULL, CHECK >= 0 | Points awarded for this purchase |

## Table: LOYALTY_POINTS

### Description
Tracks all loyalty point transactions including earnings, redemptions, and expirations.

### Columns

| Column Name | Data Type | Nullable | Key | Default | Constraints | Description |
|-------------|-----------|----------|-----|---------|-------------|-------------|
| transaction_id | NUMBER(15) | No | PK | Generated | PRIMARY KEY, NOT NULL | Unique identifier for each point transaction |
| customer_id | NUMBER(10) | No | FK |  | FOREIGN KEY REFERENCES CUSTOMERS(customer_id), NOT NULL | Reference to the customer |
| transaction_date | DATE | No |  | SYSDATE | NOT NULL | Date and time of the transaction |
| transaction_type | VARCHAR2(20) | No |  |  | NOT NULL, CHECK IN ('EARNED','REDEMPTION','EXPIRED','BONUS','ADJUSTMENT') | Type of point transaction |
| points_amount | NUMBER(10) | No |  |  | NOT NULL | Number of points (+ for earned, - for redeemed) |
| purchase_id | NUMBER(12) | Yes | FK |  | FOREIGN KEY REFERENCES PURCHASES(purchase_id) | Reference to purchase (if applicable) |
| description | VARCHAR2(200) | Yes |  |  |  | Description of the transaction |
| expiration_date | DATE | Yes |  |  |  | Date when points will expire (if applicable) |
| bonus_type | VARCHAR2(30) | Yes |  |  | CHECK IN ('SIGNUP','REFERRAL','SEASONAL','PROMOTIONAL') | Type of bonus (for bonus transactions) |

## Table: REWARDS

### Description
Defines available rewards that customers can redeem with their loyalty points.

### Columns

| Column Name | Data Type | Nullable | Key | Default | Constraints | Description |
|-------------|-----------|----------|-----|---------|-------------|-------------|
| reward_id | NUMBER(8) | No | PK | Generated | PRIMARY KEY, NOT NULL | Unique identifier for each reward |
| reward_name | VARCHAR2(100) | No |  |  | NOT NULL | Name of the reward |
| reward_description | VARCHAR2(500) | Yes |  |  |  | Detailed description of the reward |
| points_required | NUMBER(8) | No |  |  | NOT NULL, CHECK > 0 | Number of points required to redeem |
| reward_category | VARCHAR2(50) | No |  |  | NOT NULL | Category of the reward (e.g., 'Food', 'Merchandise') |
| availability_status | VARCHAR2(20) | No |  | 'ACTIVE' | NOT NULL, CHECK IN ('ACTIVE','INACTIVE','LIMITED') | Current availability status |
| limited_quantity | NUMBER(6) | Yes |  |  | CHECK >= 0 | Quantity available (if limited) |
| start_date | DATE | Yes |  |  |  | Date when reward becomes available |
| end_date | DATE | Yes |  |  |  | Date when reward expires |
| reward_cost | NUMBER(8,2) | No |  | 0 | NOT NULL, CHECK >= 0 | Cost to business for fulfilling reward |

## Table: REDEMPTIONS

### Description
Records all reward redemptions by customers.

### Columns

| Column Name | Data Type | Nullable | Key | Default | Constraints | Description |
|-------------|-----------|----------|-----|---------|-------------|-------------|
| redemption_id | NUMBER(12) | No | PK | Generated | PRIMARY KEY, NOT NULL | Unique identifier for each redemption |
| customer_id | NUMBER(10) | No | FK |  | FOREIGN KEY REFERENCES CUSTOMERS(customer_id), NOT NULL | Reference to the customer |
| reward_id | NUMBER(8) | No | FK |  | FOREIGN KEY REFERENCES REWARDS(reward_id), NOT NULL | Reference to the reward |
| redemption_date | DATE | No |  | SYSDATE | NOT NULL | Date and time of redemption |
| points_used | NUMBER(8) | No |  |  | NOT NULL, CHECK > 0 | Number of points used for redemption |
| confirmation_code | VARCHAR2(20) | No |  | Generated | NOT NULL, UNIQUE | Unique code for redemption confirmation |
| redemption_status | VARCHAR2(20) | No |  | 'PENDING' | NOT NULL, CHECK IN ('PENDING','COMPLETED','CANCELLED','EXPIRED') | Current status of redemption |
| fulfillment_date | DATE | Yes |  |  |  | Date when reward was fulfilled |
| tracking_number | VARCHAR2(50) | Yes |  |  |  | Tracking number for shipped rewards |

## Table: HOLIDAYS

### Description
Stores public holidays that affect business operations and employee restrictions.

### Columns

| Column Name | Data Type | Nullable | Key | Default | Constraints | Description |
|-------------|-----------|----------|-----|---------|-------------|-------------|
| holiday_id | NUMBER(6) | No | PK | Generated | PRIMARY KEY, NOT NULL | Unique identifier for each holiday |
| holiday_date | DATE | No |  |  | NOT NULL, UNIQUE | Date of the holiday |
| holiday_name | VARCHAR2(100) | No |  |  | NOT NULL | Name of the holiday |
| description | VARCHAR2(200) | Yes |  |  |  | Description of the holiday |
| is_active | VARCHAR2(1) | No |  | 'Y' | NOT NULL, CHECK IN ('Y','N') | Whether holiday is currently active |
| created_date | DATE | No |  | SYSDATE | NOT NULL | Date record was created |

## Table: AUDIT_LOG

### Description
Comprehensive audit trail of all database operations for security and compliance.

### Columns

| Column Name | Data Type | Nullable | Key | Default | Constraints | Description |
|-------------|-----------|----------|-----|---------|-------------|-------------|
| audit_id | NUMBER(20) | No | PK | Generated | PRIMARY KEY, NOT NULL | Unique identifier for each audit record |
| event_timestamp | TIMESTAMP(6) | No |  | SYSTIMESTAMP | NOT NULL | Timestamp of the audited event |
| user_name | VARCHAR2(30) | No |  |  | NOT NULL | Database user who performed the operation |
| session_id | VARCHAR2(40) | Yes |  |  |  | Database session identifier |
| ip_address | VARCHAR2(45) | Yes |  |  |  | Client IP address |
| table_name | VARCHAR2(30) | No |  |  | NOT NULL | Name of the table affected |
| operation | VARCHAR2(10) | No |  |  | NOT NULL, CHECK IN ('INSERT','UPDATE','DELETE','SELECT') | Type of database operation |
| row_key | VARCHAR2(100) | Yes |  |  |  | Identifier for the affected row(s) |
| old_values | CLOB | Yes |  |  |  | JSON representation of old values (for UPDATE/DELETE) |
| new_values | CLOB | Yes |  |  |  | JSON representation of new values (for INSERT/UPDATE) |
| success_flag | VARCHAR2(1) | No |  | 'Y' | NOT NULL, CHECK IN ('Y','N') | Whether operation was successful |
| error_message | VARCHAR2(4000) | Yes |  |  |  | Error message if operation failed |
| execution_time_ms | NUMBER(10) | Yes |  |  | CHECK >= 0 | Execution time in milliseconds |

## Sequences

### Sequence: CUSTOMERS_SEQ
Generates unique identifiers for the CUSTOMERS table.
* **Min Value:** 1
* **Max Value:** 9999999999
* **Increment By:** 1
* **Cache:** 20

### Sequence: PURCHASES_SEQ
Generates unique identifiers for the PURCHASES table.
* **Min Value:** 1
* **Max Value:** 999999999999
* **Increment By:** 1
* **Cache:** 20

### Sequence: LOYALTY_POINTS_SEQ
Generates unique identifiers for the LOYALTY_POINTS table.
* **Min Value:** 1
* **Max Value:** 999999999999999
* **Increment By:** 1
* **Cache:** 20

### Sequence: REWARDS_SEQ
Generates unique identifiers for the REWARDS table.
* **Min Value:** 1
* **Max Value:** 99999999
* **Increment By:** 1
* **Cache:** 20

### Sequence: REDEMPTIONS_SEQ
Generates unique identifiers for the REDEMPTIONS table.
* **Min Value:** 1
* **Max Value:** 999999999999
* **Increment By:** 1
* **Cache:** 20

### Sequence: HOLIDAYS_SEQ
Generates unique identifiers for the HOLIDAYS table.
* **Min Value:** 1
* **Max Value:** 999999
* **Increment By:** 1
* **Cache:** 20

### Sequence: AUDIT_LOG_SEQ
Generates unique identifiers for the AUDIT_LOG table.
* **Min Value:** 1
* **Max Value:** 999999999999999999
* **Increment By:** 1
* **Cache:** 20

## Views

### View: CUSTOMER_SUMMARY
Provides a consolidated view of customer information with calculated metrics.

### View: PURCHASE_HISTORY
Shows detailed purchase history for each customer.

### View: POINT_BALANCE
Displays current point balances for all customers.

### View: REWARD_CATALOG
Lists all available rewards with their details.

### View: REDEMPTION_HISTORY
Shows complete redemption history for customers.

### View: AUDIT_LOG_SUMMARY
Simplified view of audit logs for easier querying.

## Indexes

### Index: CUSTOMERS_PHONE_IDX
Improves performance of phone number lookups.
* **Table:** CUSTOMERS
* **Columns:** phone

### Index: CUSTOMERS_EMAIL_IDX
Improves performance of email lookups.
* **Table:** CUSTOMERS
* **Columns:** email

### Index: PURCHASES_CUSTOMER_IDX
Improves performance of customer purchase queries.
* **Table:** PURCHASES
* **Columns:** customer_id, purchase_date

### Index: LOYALTY_POINTS_CUSTOMER_IDX
Improves performance of customer point transaction queries.
* **Table:** LOYALTY_POINTS
* **Columns:** customer_id, transaction_date

### Index: LOYALTY_POINTS_TYPE_IDX
Improves performance of transaction type queries.
* **Table:** LOYALTY_POINTS
* **Columns:** transaction_type

### Index: REDEMPTIONS_CUSTOMER_IDX
Improves performance of customer redemption queries.
* **Table:** REDEMPTIONS
* **Columns:** customer_id, redemption_date

### Index: REDEMPTIONS_STATUS_IDX
Improves performance of redemption status queries.
* **Table:** REDEMPTIONS
* **Columns:** redemption_status

### Index: HOLIDAYS_DATE_IDX
Improerves performance of holiday date queries.
* **Table:** HOLIDAYS
* **Columns:** holiday_date

### Index: AUDIT_LOG_TIMESTAMP_IDX
Improves performance of audit log timestamp queries.
* **Table:** AUDIT_LOG
* **Columns:** event_timestamp

### Index: AUDIT_LOG_USER_IDX
Improves performance of audit log user queries.
* **Table:** AUDIT_LOG
* **Columns:** user_name

## Constraints

### Primary Keys
All tables have primary keys defined on their respective ID columns.

### Foreign Keys
* PURCHASES.customer_id → CUSTOMERS.customer_id
* LOYALTY_POINTS.customer_id → CUSTOMERS.customer_id
* LOYALTY_POINTS.purchase_id → PURCHASES.purchase_id
* REDEMPTIONS.customer_id → CUSTOMERS.customer_id
* REDEMPTIONS.reward_id → REWARDS.reward_id

### Check Constraints
Various check constraints ensure data integrity:
* Customer tier levels are restricted to predefined values
* Point amounts are non-negative
* Transaction types are restricted to predefined values
* Redemption statuses are restricted to predefined values
* Holiday active status is restricted to 'Y' or 'N'

### Unique Constraints
* CUSTOMERS.phone (unique phone numbers)
* CUSTOMERS.email (unique email addresses)
* PURCHASES.receipt_number (unique receipt numbers)
* REDEMPTIONS.confirmation_code (unique confirmation codes)
* HOLIDAYS.holiday_date (unique holiday dates)

## Relationships

### Customer to Purchases
One-to-Many relationship. One customer can have many purchases.

### Customer to Loyalty Points
One-to-Many relationship. One customer can have many point transactions.

### Customer to Redemptions
One-to-Many relationship. One customer can have many reward redemptions.

### Purchases to Loyalty Points
One-to-Many relationship. One purchase can generate many point transactions.

### Rewards to Redemptions
One-to-Many relationship. One reward can be redeemed many times.

## Data Types

### NUMBER
Used for numeric data including integers and decimals.
* **Precision:** Maximum number of digits
* **Scale:** Number of digits to the right of the decimal point

### VARCHAR2
Used for variable-length character strings.
* **Maximum Length:** Specified in characters

### DATE
Used for date and time values.
* **Format:** YYYY-MM-DD HH24:MI:SS

### TIMESTAMP
Used for high-precision date and time values.
* **Precision:** Up to 6 decimal places for fractional seconds

### CLOB
Used for large character data.
* **Maximum Size:** 4GB

## Business Rules

### Point Calculation
* 1 point per $1 spent (base calculation)
* Tier bonuses: Silver (10%), Gold (20%), Platinum (30%)
* Minimum purchase of $5 required to earn points

### Point Expiration
* Points expire after 18 months of inactivity
* Inactivity is measured from the last point transaction date

### Reward Redemption
* Customers must have sufficient points to redeem rewards
* Some rewards may have quantity limitations
* Rewards may have availability dates

### Customer Tiers
* Bronze: 0-999 points
* Silver: 1000-4999 points
* Gold: 5000-9999 points
* Platinum: 10000+ points

## Security Considerations

### Data Encryption
* Personally identifiable information (PII) should be encrypted at rest
* Communication with the database should use encrypted connections

### Access Control
* Role-based access control should be implemented
* Audit logging should capture all access attempts

### Data Retention
* Audit logs should be retained for a minimum of 7 years
* Customer data should be retained according to legal requirements

## Performance Considerations

### Indexing Strategy
* All foreign key columns should be indexed
* Frequently queried columns should be indexed
* Composite indexes should be used for multi-column queries

### Partitioning
* Large tables (AUDIT_LOG) should be partitioned by date
* Partition pruning should be leveraged for performance

### Statistics
* Table and index statistics should be regularly updated
* Query optimizer should have current statistics for optimal execution plans