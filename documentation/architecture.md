# System Architecture

## Project Title
Customer Loyalty Points & Rewards Automation System

## Student Information
* **Name:** Frank Nasiimwe
* **Student ID:** 26652
* **Course:** Database Development with PL/SQL (INSY 8311)
* **Institution:** Adventist University of Central Africa (AUCA)

## Overview
This document describes the system architecture of the Customer Loyalty Points & Rewards Automation System. The architecture encompasses the database design, PL/SQL components, integration points, and security measures that enable the system to automatically manage customer loyalty programs.

## High-Level Architecture

### System Context Diagram
```
┌─────────────────────────────────────────────────────────────────────┐
│                        EXTERNAL SYSTEMS                             │
├─────────────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐  │
│  │   POS System    │    │  Mobile App     │    │   Web Portal    │  │
│  │ (Transactions)  │    │ (Self-service)  │    │ (Management)    │  │
│  └─────────────────┘    └─────────────────┘    └─────────────────┘  │
└──────────────────────────────┬───────────────────────────────────────┘
                               │
                    ┌──────────▼──────────┐
                    │  LOYALTY ENGINE     │
                    │                     │
                    │  ┌───────────────┐  │
                    │  │  Database     │  │
                    │  │  (Oracle)     │  │
                    │  └───────────────┘  │
                    │                     │
                    │  ┌───────────────┐  │
                    │  │  PL/SQL       │  │
                    │  │  Components   │  │
                    │  └───────────────┘  │
                    │                     │
                    │  ┌───────────────┐  │
                    │  │  Business     │  │
                    │  │  Logic        │  │
                    │  └───────────────┘  │
                    └──────────┬──────────┘
                               │
                    ┌──────────▼──────────┐
                    │   REPORTING & BI    │
                    │                     │
                    │  ┌───────────────┐  │
                    │  │  Analytics    │  │
                    │  │  Dashboard    │  │
                    │  └───────────────┘  │
                    └─────────────────────┘
```

## Database Layer

### Physical Architecture
The database layer consists of an Oracle Database 12c or higher instance with the following components:

1. **Pluggable Database (PDB)**
   * Service Name: tue_26652_frank_loyalty_db
   * Dedicated to the loyalty program system
   * Isolated from other database applications

2. **Tablespaces**
   * **LOYALTY_DATA**: Primary data storage
   * **LOYALTY_INDEX**: Index storage for performance
   * **LOYALTY_TEMP**: Temporary storage for operations
   * **LOYALTY_UNDO**: Undo data for transaction management

3. **Database Users**
   * **LOYALTY_OWNER**: Primary owner with full privileges
   * **LOYALTY_APP**: Application user with limited privileges
   * **LOYALTY_READ**: Read-only user for reporting

### Logical Architecture
The database contains seven main tables organized to support the loyalty program functionality:

1. **CUSTOMERS**: Core entity storing customer information
2. **PURCHASES**: Transaction entity recording customer purchases
3. **LOYALTY_POINTS**: Transactional entity tracking point movements
4. **REWARDS**: Catalog entity defining available rewards
5. **REDEMPTIONS**: Transactional entity recording reward claims
6. **HOLIDAYS**: Reference entity for business rule enforcement
7. **AUDIT_LOG**: Security entity for compliance tracking

## PL/SQL Component Layer

### Procedures
Stored procedures encapsulate business logic for common operations:

1. **ADD_LOYALTY_POINTS**
   * Calculates and adds points for purchases
   * Applies tier-based bonuses
   * Updates customer point balances

2. **REDEEM_REWARD**
   * Validates point sufficiency
   * Processes reward redemption
   * Generates confirmation codes

3. **EXPIRE_POINTS**
   * Identifies expired points
   * Updates point balances
   * Records expiration transactions

4. **UPDATE_CUSTOMER_TIER**
   * Calculates customer tier based on points
   * Updates customer record
   * Triggers welcome communications

### Functions
Functions provide reusable calculations and validations:

1. **CALCULATE_POINTS**
   * Computes points for purchase amounts
   * Applies business rules
   * Returns point values

2. **GET_CUSTOMER_POINTS**
   * Retrieves current point balance
   * Includes pending transactions
   * Returns formatted values

3. **VALIDATE_REDEMPTION**
   * Checks reward availability
   * Validates point sufficiency
   * Returns validation status

4. **IS_ELIGIBLE_FOR_TIER**
   * Determines customer tier eligibility
   * Compares point thresholds
   * Returns tier level

### Packages
Packages group related functionality for maintainability:

1. **LOYALTY_PKG**
   * Consolidates all loyalty program functions
   * Provides unified interface
   * Manages package state

2. **SECURITY_PKG**
   * Handles authentication and authorization
   * Manages session information
   * Implements audit logging

3. **REPORTING_PKG**
   * Generates analytical reports
   * Aggregates performance metrics
   * Formats output for dashboards

### Triggers
Triggers automate business rule enforcement:

1. **Simple Triggers**
   * Enforce data integrity
   * Log audit information
   * Block unauthorized operations

2. **Compound Triggers**
   * Optimize performance for bulk operations
   * Manage global variables
   * Coordinate statement and row level actions

### Cursors
Cursors enable batch processing:

1. **Batch Processing Cursors**
   * Process large datasets efficiently
   * Handle point expirations
   * Update customer tiers

2. **Analytics Cursors**
   * Aggregate performance data
   * Generate reports
   * Support business intelligence

## Integration Layer

### Application Programming Interface (API)
The system exposes functionality through database APIs:

1. **Point Management API**
   * Add points for purchases
   * Check point balances
   * Process point adjustments

2. **Reward Management API**
   * Browse available rewards
   * Redeem rewards
   * Track redemption status

3. **Customer Management API**
   * Register new customers
   * Update customer information
   * Manage customer tiers

### Data Exchange Formats
Data is exchanged using standard formats:

1. **JSON**
   * Used for configuration data
   * Supports flexible data structures
   * Compatible with modern applications

2. **XML**
   * Used for formal document exchange
   * Supports schema validation
   * Compatible with enterprise systems

3. **CSV**
   * Used for bulk data imports/exports
   * Efficient for large datasets
   * Compatible with spreadsheet applications

## Security Layer

### Authentication
The system implements robust authentication mechanisms:

1. **Database Authentication**
   * Native Oracle authentication
   * Secure password policies
   * Account locking mechanisms

2. **Application Authentication**
   * Session-based authentication
   * Token management
   * Single sign-on integration

### Authorization
Fine-grained access control is enforced:

1. **Role-Based Access Control (RBAC)**
   * Predefined roles for different user types
   * Privilege separation
   * Least privilege principle

2. **Row-Level Security**
   * Customer data isolation
   * Department-based access
   * Dynamic data filtering

### Encryption
Data protection is implemented at multiple levels:

1. **Data-at-Rest Encryption**
   * Transparent Data Encryption (TDE)
   * Column-level encryption for PII
   * Key management

2. **Data-in-Transit Encryption**
   * SSL/TLS for network communications
   * Encrypted database connections
   * Secure API endpoints

### Auditing
Comprehensive audit trails are maintained:

1. **Database Auditing**
   * All DML operations logged
   * User activity monitoring
   * Compliance reporting

2. **Business Auditing**
   * Point transaction tracking
   * Reward redemption logging
   * Customer tier changes

## Performance Layer

### Indexing Strategy
Optimized indexing improves query performance:

1. **Primary Indexes**
   * Primary key indexes on all tables
   * Foreign key indexes for joins
   * Unique constraint indexes

2. **Secondary Indexes**
   * Performance indexes on frequently queried columns
   * Composite indexes for multi-column queries
   * Function-based indexes for computed values

### Partitioning
Large tables are partitioned for performance:

1. **AUDIT_LOG Partitioning**
   * Range partitioning by date
   * Monthly partition maintenance
   * Archive strategy for old data

2. **LOYALTY_POINTS Partitioning**
   * Range partitioning by transaction date
   * Quarterly partition maintenance
   * Performance optimization for analytics

### Caching
In-memory caching reduces database load:

1. **Database Result Cache**
   * Frequently accessed reference data
   * Static configuration values
   * Lookup table results

2. **Application Cache**
   * Session data caching
   * User preference storage
   * Temporary calculation results

## Business Intelligence Layer

### Analytics Engine
The system provides built-in analytics capabilities:

1. **Window Functions**
   * Customer ranking and segmentation
   * Trend analysis
   * Comparative reporting

2. **Aggregation Functions**
   * Summary statistics
   * Performance metrics
   * KPI calculations

### Reporting Framework
Structured reporting capabilities:

1. **Standard Reports**
   * Daily transaction summaries
   * Monthly performance reports
   * Quarterly business reviews

2. **Ad-Hoc Reporting**
   * Custom query builder
   * Interactive dashboards
   * Export capabilities

## Deployment Architecture

### Development Environment
* **Database**: Oracle Database 12c Express Edition
* **Tools**: Oracle SQL Developer
* **Version Control**: Git with GitHub integration
* **Documentation**: Markdown format

### Testing Environment
* **Database**: Oracle Database 12c Standard Edition
* **Load Testing**: Simulated concurrent users
* **Performance Testing**: Response time measurements
* **Security Testing**: Penetration testing tools

### Production Environment
* **Database**: Oracle Database 12c Enterprise Edition
* **High Availability**: Data Guard configuration
* **Backup**: RMAN automated backups
* **Monitoring**: OEM Grid Control

## Scalability Considerations

### Horizontal Scaling
* **Read Replicas**: Multiple read-only instances
* **Sharding**: Customer data distribution
* **Load Balancing**: Connection pooling

### Vertical Scaling
* **Resource Allocation**: CPU and memory scaling
* **Storage Expansion**: Dynamic storage provisioning
* **Performance Tuning**: Query optimization

## Disaster Recovery

### Backup Strategy
* **Full Backups**: Weekly full database backups
* **Incremental Backups**: Daily incremental backups
* **Archived Logs**: Continuous archiving

### Recovery Procedures
* **Point-in-Time Recovery**: Restore to specific timestamps
* **Failover**: Automatic switching to standby systems
* **Data Validation**: Post-recovery data integrity checks

## Monitoring and Maintenance

### Health Monitoring
* **Database Metrics**: Performance counters
* **Application Metrics**: Response times
* **Business Metrics**: Transaction volumes

### Maintenance Windows
* **Scheduled Maintenance**: Weekly maintenance windows
* **Patch Management**: Quarterly updates
* **Performance Tuning**: Monthly optimization

## Technology Stack

### Database Technologies
* **Oracle Database 12c**: Primary database platform
* **PL/SQL**: Stored procedure language
* **SQL**: Query language

### Development Tools
* **Oracle SQL Developer**: Primary development IDE
* **Git**: Version control system
* **Markdown**: Documentation format

### Monitoring Tools
* **Oracle Enterprise Manager**: Database monitoring
* **Custom Scripts**: Automated health checks
* **Log Analysis**: Audit trail review

### Reporting Tools
* **Oracle Analytics**: Business intelligence platform
* **Custom Dashboards**: HTML5/JavaScript interfaces
* **Export Utilities**: Data export capabilities

## Future Enhancements

### Cloud Migration
* **Oracle Cloud Infrastructure**: Planned migration target
* **Autonomous Database**: Potential future platform
* **Serverless Computing**: Event-driven processing

### Advanced Analytics
* **Machine Learning**: Predictive customer behavior
* **Real-time Processing**: Stream analytics
* **Artificial Intelligence**: Intelligent recommendations

### Mobile Integration
* **Native Mobile Apps**: iOS and Android applications
* **Push Notifications**: Real-time alerts
* **Offline Capabilities**: Disconnected operation support

## Conclusion
The Customer Loyalty Points & Rewards Automation System architecture provides a robust, scalable, and secure foundation for managing customer loyalty programs. The layered approach ensures separation of concerns while maintaining performance and reliability. The modular design enables future enhancements and integrations while preserving existing functionality.