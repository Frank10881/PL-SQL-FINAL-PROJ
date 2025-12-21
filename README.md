🎯 Customer Loyalty Points & Rewards Automation System

======================================================================

## 🎓 Personal Information

**Student:** Frank Nasiimwe  
**Student ID:** 26652  
**Program:** IT – Software Engineering  
**Course:** INSY 8311 | Database Development with PL/SQL  
**Institution:** Adventist University of Central Africa (AUCA)  
**Lecturer:** Eric Maniraguha  
**Academic Year:** 2025–2026 | Semester I  

**Project Title:** Customer Loyalty Points & Rewards Automation System  
**Database:** Oracle 19c / 21c  
**Project Date:** December 2025  

---

## 📑 Project Phases – Table of Content

| Phase | Primary Objective | Key Deliverable |
|-------|-------------------|-----------------|
| I | Problem Identification | Project Overview |
| II | Business Process Modeling | BPMN Diagram |
| III | Logical Database Design | ER Diagram + Data Dictionary |
| IV | Database Creation | Oracle PDB + Configuration |
| V | Table Implementation | CREATE & INSERT Scripts |
| VI | PL/SQL Development | Procedures, Functions, Packages |
| VII | Advanced Programming | Triggers, Auditing, Security |
| VIII | Final Documentation | GitHub Repository + Presentation |

---

# ✅ Phase I: Problem Identification

## 🎯 Project Overview

This is a multi-phase individual capstone project focused on **Oracle Database Design, PL/SQL Programming, and Business Intelligence**.  
The system automates customer loyalty programs, point calculation, reward redemption, and business analytics for retail businesses.

## ⚠️ Problem Statement

Retail businesses currently face:
- Manual loyalty point tracking leading to **calculation errors**
- **Inconsistent reward distribution** causing customer dissatisfaction
- Lack of **real-time business analytics**
- Weak **security and audit tracking**
- Paper-based loyalty cards causing **operational inefficiencies**

These problems result in:
- Revenue loss  
- Customer dissatisfaction  
- Inefficient loyalty operations  
- Poor strategic decision-making  

## 🛠 Proposed Solution

A **PL/SQL-based Customer Loyalty Points & Rewards Automation System** that:
- Automates all loyalty point calculations  
- Prevents fraudulent redemptions using triggers  
- Tracks customer purchases and rewards  
- Produces real-time business intelligence reports  

---

# ✅ Phase II: Business Process Modeling

## 👥 System Actors

- **Cashier** – Processes customer purchases and awards points  
- **Store Manager** – Monitors loyalty program performance  
- **Marketing Team** – Analyzes customer behavior and trends  
- **System Admin** – Manages users and security  
- **Customer** – Earns points and redeems rewards  

## 🔄 Core Process Flow

1. Customer makes a purchase  
2. System automatically calculates and awards points  
3. Customer accumulates points over time  
4. Customer redeems rewards using points  
5. System updates point balances  
6. Audit logs capture all transactions  

## 📌 BPMN Diagram

> <img width="24719" height="10708" alt="Customer Loyalty System-2025-12-19-120135" src="https://github.com/user-attachments/assets/c7bf8b4f-687e-4ddc-bd37-c68dcd079638" />


---

# ✅ Phase III: Logical Database Design

## 📊 Entities (7 Tables)

| Table Name | Description |
|-----------|-------------|
| CUSTOMERS | Customer information and loyalty tiers |
| PURCHASES | Customer purchase transactions |
| LOYALTY_POINTS | Point transactions and balances |
| REWARDS | Available rewards for redemption |
| REDEMPTIONS | Customer reward redemptions |
| HOLIDAYS | Public holidays for business rules |
| AUDIT_LOG | System audit trail |

## 🧩 ER Diagram
<img width="5366" height="3655" alt="Customer Loyalty Points-2025-12-19-103308" src="https://github.com/user-attachments/assets/bbe90788-2808-448a-aea3-0e5bf212990e" />

## ✅ Normalization
1NF: Atomic values  
2NF: No partial dependencies  
3NF: No transitive dependencies  

Database is fully compliant with **Third Normal Form (3NF)**.

---

# ✅ Phase IV: Database Creation

## 🗄️ Pluggable Database (PDB)

PDB Name: tue_26652_frank_loyalty_db  
Admin User: loyalty_owner  
Password: frank  

```sql
CREATE PLUGGABLE DATABASE tue_26652_frank_loyalty_db
ADMIN USER admin IDENTIFIED BY frank
FILE_NAME_CONVERT = (
 '/opt/oracle/oradata/CDB/pdbseed/',
 '/opt/oracle/oradata/CDB/tue_26652_frank_loyalty_db/'
);

ALTER PLUGGABLE DATABASE tue_26652_frank_loyalty_db OPEN;
ALTER SESSION SET CONTAINER = tue_26652_frank_loyalty_db;
```

---

# ✅ Phase V: Table Implementation & Data Insertion

Tables Implemented:
CUSTOMERS  
PURCHASES  
LOYALTY_POINTS  
REWARDS  
REDEMPTIONS  
HOLIDAYS  
AUDIT_LOG  

Validation Queries:
```sql
SELECT COUNT(*) FROM customers;
SELECT COUNT(*) FROM purchases;
SELECT COUNT(*) FROM loyalty_points;
SELECT COUNT(*) FROM rewards;
SELECT COUNT(*) FROM redemptions;
SELECT COUNT(*) FROM holidays;
SELECT COUNT(*) FROM audit_log;
```

![all tables](![loyalty_tables](https://github.com/user-attachments/assets/13e6dce6-adb2-4205-a3c0-1c769f128eaa)

---

# ✅ Phase VI: PL/SQL Development

Package Name:
LOYALTY_PKG

--------------------------------------------------

Procedures:
- ADD_LOYALTY_POINTS
- REDEEM_REWARD
- EXPIRE_POINTS
- UPDATE_CUSTOMER_TIER
- PROCESS_BULK_PURCHASES

--------------------------------------------------

Functions:
- CALCULATE_POINTS
- GET_CUSTOMER_POINTS
- VALIDATE_REDEMPTION
- IS_ELIGIBLE_FOR_TIER
- GET_CUSTOMER_TIER

--------------------------------------------------

Window Functions Used:
- ROW_NUMBER()
- RANK()
- LAG()
- LEAD()

--------------------------------------------------

# ✅ Phase VII: Advanced Programming & Auditing

### 🔒 Business Rule
No `INSERT`, `UPDATE`, or `DELETE` allowed on:
- Weekdays (Monday–Friday)  
- Registered public holidays  

### 🧾 Audit Table
```sql
CREATE TABLE audit_log (
  audit_id NUMBER GENERATED AS IDENTITY PRIMARY KEY,
  event_timestamp TIMESTAMP(6) DEFAULT SYSTIMESTAMP,
  user_name VARCHAR2(30),
  table_name VARCHAR2(30),
  operation VARCHAR2(10),
  success_flag VARCHAR2(1),
  error_message VARCHAR2(4000)
);
```

## ✅ Phase VIII: Final Documentation & Presentation

- ✅ GitHub Repository Completed  
- ✅ Final PowerPoint Presentation  
- ✅ Business Intelligence Outputs  
- ✅ System Testing Completed  

---

## 📈 Business Intelligence

The system supports:
- Customer engagement analytics  
- Revenue impact analysis  
- Reward redemption trends  
- Customer lifetime value calculations  

**project presantation**
[Customer Loyalty Points & Rewards Automation System.pptx](https://github.com/user-attachments/files/24279230/Customer.Loyalty.Points.Rewards.Automation.System.pptx)
 ]
---

## 🧠 Key Achievements
- 7 Fully normalized tables  
- Secure loyalty program with business rule enforcement  
- Automated point calculation and reward redemption  
- Audit-ready system  
- BI-ready analytical queries  

---

## 💬 Acknowledgment
I sincerely thank **Mr. Eric Maniraguha** and the **IT Faculty at AUCA** for their guidance, support, and mentorship throughout this course and project.

---

## 📚 References
- Oracle Corporation (2021). *Oracle Database 21c Documentation*  
- Feuerstein, S. & Pribyl, B. (2021). *Oracle PL/SQL Programming*  
- Connolly & Begg (2015). *Database Systems*  
- Elmasri & Navathe (2016). *Fundamentals of Database Systems*  

---

## 📄 License
This project is submitted as part of the Capstone Project for **Database Development with PL/SQL**, Academic Year 2025–2026,  
Adventist University of Central Africa (AUCA).  

*"Customer loyalty is the key to sustainable business growth."*
