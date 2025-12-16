# Customer Loyalty Points & Rewards Automation System

## Project Overview
This is a comprehensive PL/SQL Oracle database project that automates customer loyalty programs. The system automatically awards points after each purchase, manages reward redemptions, handles promotional bonuses, and expires unused points. It functions as a backend engine integrated with business sales systems, ensuring accuracy, minimizing fraud, and improving efficiency.

## Student Information
* **Name:** Frank Nasiimwe
* **Student ID:** 26652
* **Course:** Database Development with PL/SQL (INSY 8311)
* **Institution:** Adventist University of Central Africa (AUCA)

## Problem Statement
Many businesses still track loyalty points manually, causing delays, errors, and inconsistent reward distribution. This project proposes an automated PL/SQL-based Customer Loyalty Points & Rewards Automation System to eliminate these issues and provide real-time, accurate loyalty program management.

## Key Objectives
* Automate point calculation and awarding after each purchase
* Manage reward redemptions with validation and fraud prevention
* Handle promotional bonuses and special campaigns
* Automatically expire unused points based on business rules
* Provide comprehensive analytics and business intelligence
* Ensure data security and audit compliance

## Quick Start Instructions
1. **Database Setup:**
   * Create Oracle Pluggable Database using scripts in `database/scripts/create_pdb.sql`
   * Configure tablespaces using `database/scripts/tablespaces.sql`
   * Set up user accounts using `database/scripts/user_setup.sql`

2. **Table Creation:**
   * Run `database/scripts/create_tables.sql` to create all database tables
   * Execute `database/scripts/insert_data.sql` to populate with sample data

3. **PL/SQL Components:**
   * Deploy procedures using `database/scripts/loyalty_procedures.sql`
   * Create functions using `database/scripts/loyalty_functions.sql`
   * Install packages using `database/scripts/loyalty_package.sql`

4. **Advanced Features:**
   * Implement triggers using `database/scripts/simple_triggers.sql` and `database/scripts/compound_trigger.sql`
   * Set up auditing using `database/scripts/audit_log_table.sql` and `database/scripts/audit_logging_function.sql`

## Links to Documentation
* [Database Design Documentation](database/documentation/schema_design.md)
* [Data Dictionary](documentation/data_dictionary.md)
* [System Architecture](documentation/architecture.md)
* [Design Decisions](documentation/design_decisions.md)
* [Business Intelligence Requirements](business_intelligence/bi_requirements.md)
* [KPI Definitions](business_intelligence/kpi_definitions.md)

## Repository Structure
```
customer-loyalty-project/
├── README.md
├── database/
│   ├── scripts/
│   └── documentation/
├── queries/
├── business_intelligence/
├── screenshots/
└── documentation/
```

## Technologies Used
* Oracle Database 12c or higher
* PL/SQL for stored procedures, functions, and triggers
* SQL for data definition and manipulation
* Oracle SQL Developer for development and testing

## License
This project is for educational purposes only as part of the Database Development with PL/SQL course at AUCA.