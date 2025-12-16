# Design Decisions

## Project Title
Customer Loyalty Points & Rewards Automation System

## Student Information
* **Name:** Frank Nasiimwe
* **Student ID:** 26652
* **Course:** Database Development with PL/SQL (INSY 8311)
* **Institution:** Adventist University of Central Africa (AUCA)

## Overview
This document captures the key design decisions made during the development of the Customer Loyalty Points & Rewards Automation System. Each decision includes the rationale, alternatives considered, and the impact on the overall system.

## Database Design Decisions

### 1. Choice of Database Platform

#### Decision
Use Oracle Database 12c as the primary database platform.

#### Rationale
* Oracle Database provides robust PL/SQL support essential for complex business logic
* Enterprise-grade features for security, auditing, and compliance
* Strong transaction management and ACID compliance
* Extensive tooling ecosystem (SQL Developer, OEM, etc.)
* Familiarity with the platform from coursework

#### Alternatives Considered
* **PostgreSQL**: Open-source alternative with good PL/pgSQL support
* **Microsoft SQL Server**: Strong T-SQL capabilities and integration with Microsoft ecosystem
* **MySQL**: Popular open-source option with stored procedure support

#### Impact
* Positive: Leverages extensive PL/SQL features for complex triggers and procedures
* Negative: Licensing costs for production deployment
* Risk: Dependency on proprietary technology

### 2. Normalization Approach

#### Decision
Normalize database to Third Normal Form (3NF) with selective denormalization for performance.

#### Rationale
* Eliminates data redundancy and ensures consistency
* Supports flexible querying and reporting
* Enables proper referential integrity
* Balances normalization with performance needs

#### Alternatives Considered
* **Fully Normalized**: Strict adherence to all normal forms
* **Denormalized**: Star schema for data warehouse approach
* **Hybrid**: Mix of normalized and denormalized structures

#### Impact
* Positive: Reduced storage requirements and improved data integrity
* Negative: More complex joins for some queries
* Risk: Potential performance issues with complex joins

### 3. Primary Key Strategy

#### Decision
Use surrogate keys (sequences) for all primary keys.

#### Rationale
* Ensures stable, unchanging identifiers
* Simplifies foreign key relationships
* Avoids issues with natural key changes
* Provides consistent key generation mechanism

#### Alternatives Considered
* **Natural Keys**: Use existing business identifiers
* **Composite Keys**: Combine multiple columns for uniqueness
* **UUIDs**: Globally unique identifiers

#### Impact
* Positive: Stable references that won't change over time
* Negative: Additional storage overhead for key columns
* Risk: Dependency on sequence generation

### 4. Indexing Strategy

#### Decision
Implement strategic indexing focusing on high-frequency query patterns.

#### Rationale
* Improves query performance for common operations
* Supports efficient join operations
* Enables fast lookups for customer and transaction data
* Balances performance gains with write overhead

#### Alternatives Considered
* **Minimal Indexing**: Only primary and foreign key indexes
* **Over-Indexing**: Indexes on all columns
* **No Indexing**: Heap tables only

#### Impact
* Positive: Significant performance improvements for read operations
* Negative: Slight performance degradation for write operations
* Risk: Index maintenance overhead

## PL/SQL Design Decisions

### 1. Procedure vs. Function Selection

#### Decision
Use procedures for operations that modify data and functions for operations that return values.

#### Rationale
* Aligns with PL/SQL best practices
* Improves code readability and maintainability
* Enables proper error handling in procedures
* Supports functional programming patterns in functions

#### Alternatives Considered
* **All Procedures**: Use procedures exclusively
* **All Functions**: Use functions exclusively
* **Mixed Approach**: No consistent pattern

#### Impact
* Positive: Clear separation of concerns and responsibilities
* Negative: Slight complexity in choosing between procedures and functions
* Risk: Inconsistent implementation if not followed rigorously

### 2. Package Organization

#### Decision
Organize related functionality into cohesive packages.

#### Rationale
* Improves code organization and maintainability
* Enables package-level initialization
* Supports encapsulation and information hiding
* Facilitates dependency management

#### Alternatives Considered
* **Standalone Components**: Individual procedures and functions
* **Monolithic Package**: Single package for all functionality
* **Fine-Grained Packages**: Many small packages

#### Impact
* Positive: Better code organization and reusability
* Negative: Initial overhead in package design
* Risk: Over-engineering with too many packages

### 3. Exception Handling Strategy

#### Decision
Implement comprehensive exception handling with custom error codes.

#### Rationale
* Ensures robust error handling throughout the application
* Provides meaningful error messages to calling applications
* Enables proper logging and debugging
* Supports graceful degradation of functionality

#### Alternatives Considered
* **Minimal Error Handling**: Basic exception blocks only
* **No Error Handling**: Let exceptions propagate to callers
* **Generic Error Handling**: Single catch-all exception handler

#### Impact
* Positive: Improved system reliability and debuggability
* Negative: Increased code complexity
* Risk: Overhead in maintaining error codes and messages

### 4. Trigger Implementation Approach

#### Decision
Use combination of simple triggers for row-level operations and compound triggers for performance optimization.

#### Rationale
* Simple triggers provide granular control and clear logic
* Compound triggers optimize performance for bulk operations
* Separation allows for specialized handling where needed
* Follows Oracle best practices for trigger design

#### Alternatives Considered
* **Only Simple Triggers**: Row-level triggers exclusively
* **Only Compound Triggers**: Statement-level optimization only
* **No Triggers**: Application-level business rule enforcement

#### Impact
* Positive: Optimal performance with clear business rule enforcement
* Negative: Complexity in trigger coordination
* Risk: Potential for trigger conflicts or circular dependencies

## Business Logic Decisions

### 1. Point Calculation Algorithm

#### Decision
Base point calculation on $1 spent = 1 point with tier-based bonuses.

#### Rationale
* Simple and understandable for customers
* Easy to implement and maintain
* Flexible enough to accommodate tier bonuses
* Aligns with common industry practices

#### Alternatives Considered
* **Complex Multiplier System**: Variable points per dollar based on product category
* **Fixed Point Awards**: Set points for specific purchase amounts
* **Time-Based Bonuses**: Extra points during specific periods

#### Impact
* Positive: Straightforward customer understanding and system implementation
* Negative: May not maximize revenue optimization opportunities
* Risk: Simplicity may not differentiate from competitors

### 2. Point Expiration Policy

#### Decision
Points expire after 18 months of inactivity.

#### Rationale
* Balances customer retention with business sustainability
* Complies with typical industry standards
* Encourages ongoing customer engagement
* Provides reasonable timeframe for point usage

#### Alternatives Considered
* **No Expiration**: Points never expire
* **Short Expiration**: 6-12 months
* **Activity-Based**: Expire based on purchase frequency

#### Impact
* Positive: Sustainable business model with customer engagement incentive
* Negative: Potential customer dissatisfaction with expiration
* Risk: Legal compliance requirements in some jurisdictions

### 3. Customer Tier Structure

#### Decision
Four-tier system (Bronze, Silver, Gold, Platinum) based on cumulative points.

#### Rationale
* Provides clear progression path for customers
* Offers meaningful differentiation between tiers
* Aligns with established industry practices
* Enables targeted marketing and benefits

#### Alternatives Considered
* **Three-Tier System**: Simplified tier structure
* **Five-Tier System**: More granular progression
* **Continuous Scoring**: Dynamic tier based on multiple factors

#### Impact
* Positive: Clear customer goals and differentiated benefits
* Negative: Complexity in tier management and benefits
* Risk: Customer dissatisfaction with tier demotion

### 4. Reward Redemption Validation

#### Decision
Validate point sufficiency and reward availability at redemption time.

#### Rationale
* Prevents overspending of points
* Ensures reward availability
* Provides immediate feedback to customers
* Maintains system integrity

#### Alternatives Considered
* **Pre-Approval System**: Reserve points before redemption
* **Post-Processing Validation**: Validate after redemption submission
* **Trust-Based System**: Assume sufficient points

#### Impact
* Positive: System integrity and customer trust
* Negative: Potential delays in redemption processing
* Risk: Race conditions in high-volume scenarios

## Security Design Decisions

### 1. Audit Logging Approach

#### Decision
Comprehensive audit logging of all data modifications with contextual information.

#### Rationale
* Meets compliance requirements for financial systems
* Enables forensic analysis of suspicious activities
* Provides accountability for all database changes
* Supports troubleshooting and debugging

#### Alternatives Considered
* **Selective Logging**: Log only critical operations
* **Application-Level Logging**: Delegate logging to application layer
* **No Logging**: Minimal security approach

#### Impact
* Positive: Strong security posture and compliance readiness
* Negative: Storage overhead and performance impact
* Risk: Management of large audit log volumes

### 2. User Access Control

#### Decision
Role-based access control with principle of least privilege.

#### Rationale
* Simplifies permission management
* Reduces security risk from excessive permissions
* Aligns with industry security best practices
* Enables segregation of duties

#### Alternatives Considered
* **Individual Permissions**: Custom permissions per user
* **Group-Based Access**: Broad access groups
* **Administrative Access**: Elevated privileges for all users

#### Impact
* Positive: Strong security boundaries and simplified administration
* Negative: Initial overhead in role definition
* Risk: Complexity in role maintenance

### 3. Data Encryption Strategy

#### Decision
Encrypt personally identifiable information (PII) at rest and in transit.

#### Rationale
* Protects sensitive customer data
* Meets privacy regulation requirements
* Reduces liability in case of data breach
* Builds customer trust

#### Alternatives Considered
* **No Encryption**: Rely on perimeter security only
* **Full Database Encryption**: Transparent Data Encryption for entire database
* **Selective Encryption**: Encrypt only specific sensitive fields

#### Impact
* Positive: Strong data protection and regulatory compliance
* Negative: Performance overhead and key management complexity
* Risk: Key management and recovery procedures

## Performance Design Decisions

### 1. Concurrency Handling

#### Decision
Use Oracle's built-in transaction isolation and locking mechanisms.

#### Rationale
* Leverages proven database concurrency control
* Minimizes custom concurrency logic
* Ensures ACID compliance
* Reduces development complexity

#### Alternatives Considered
* **Application-Level Locking**: Custom locking mechanisms
* **Optimistic Concurrency**: Version-based conflict detection
* **No Concurrency Control**: Allow all concurrent access

#### Impact
* Positive: Reliable concurrency handling with minimal custom code
* Negative: Potential for lock contention in high-volume scenarios
* Risk: Deadlock scenarios if not properly managed

### 2. Caching Strategy

#### Decision
Use database result cache for reference data and frequently accessed information.

#### Rationale
* Leverages Oracle's built-in caching capabilities
* Reduces database load for static information
* Improves response times for common queries
* Simplifies cache invalidation

#### Alternatives Considered
* **No Caching**: Direct database access for all queries
* **Application-Level Caching**: Custom cache implementation
* **Distributed Caching**: External caching systems

#### Impact
* Positive: Improved performance for read-heavy operations
* Negative: Cache coherence considerations
* Risk: Stale data if cache invalidation fails

### 3. Batch Processing Approach

#### Decision
Implement batch processing for periodic operations using cursors and scheduled jobs.

#### Rationale
* Efficiently handles large datasets
* Minimizes impact on online transaction processing
* Enables automated maintenance operations
* Provides consistent processing patterns

#### Alternatives Considered
* **Real-Time Processing**: Process each record immediately
* **Manual Batch Processing**: Operator-initiated batches
* **Event-Driven Processing**: Trigger-based batch initiation

#### Impact
* Positive: Efficient resource utilization and predictable processing
* Negative: Delay between data changes and batch processing
* Risk: Batch job failures affecting system operations

## Integration Design Decisions

### 1. API Design Philosophy

#### Decision
Expose database functionality through well-defined PL/SQL APIs.

#### Rationale
* Leverages database-native interface capabilities
* Reduces middleware complexity
* Ensures transactional consistency
* Simplifies deployment and maintenance

#### Alternatives Considered
* **RESTful Web Services**: HTTP-based API layer
* **SOAP Services**: Formal web service contracts
* **Message Queues**: Asynchronous messaging patterns

#### Impact
* Positive: Tight integration with database operations
* Negative: Database vendor lock-in
* Risk: Network security considerations

### 2. Data Exchange Formats

#### Decision
Use JSON for structured data exchange and CSV for bulk operations.

#### Rationale
* JSON provides flexible, hierarchical data representation
* CSV offers efficient bulk data transfer
* Both formats have wide tool support
* Aligns with modern integration practices

#### Alternatives Considered
* **XML**: More verbose but highly structured
* **Proprietary Formats**: Custom binary formats
* **Flat Files**: Simple fixed-width or delimited files

#### Impact
* Positive: Broad compatibility and tool support
* Negative: Potential data transformation overhead
* Risk: Format evolution and backward compatibility

## Technology Stack Decisions

### 1. Development Environment

#### Decision
Use Oracle SQL Developer as the primary development environment.

#### Rationale
* Native integration with Oracle Database
* Comprehensive PL/SQL development features
* Familiarity from coursework
* Free and widely available

#### Alternatives Considered
* **Toad for Oracle**: Commercial alternative with advanced features
* **PL/SQL Developer**: Specialized PL/SQL IDE
* **Visual Studio Code**: Lightweight editor with extensions

#### Impact
* Positive: Seamless database integration and debugging
* Negative: Limited to Oracle ecosystem
* Risk: Dependency on specific IDE features

### 2. Version Control Strategy

#### Decision
Use Git with GitHub for source code management.

#### Rationale
* Industry-standard version control system
* Distributed architecture for team collaboration
* Integration with CI/CD pipelines
* Familiarity from coursework

#### Alternatives Considered
* **Subversion (SVN)**: Centralized version control
* **Mercurial**: Alternative distributed system
* **Database-Native Versioning**: Oracle's native features

#### Impact
* Positive: Robust version management and collaboration
* Negative: Learning curve for new team members
* Risk: Merge conflicts in collaborative development

## Future Considerations

### 1. Cloud Migration Path

#### Decision
Design with cloud migration in mind but implement for on-premises deployment.

#### Rationale
* Preserves current investment in on-premises infrastructure
* Enables future cloud adoption when appropriate
* Avoids premature cloud commitment
* Maintains flexibility for deployment options

#### Alternatives Considered
* **Cloud-First Implementation**: Design specifically for cloud deployment
* **On-Premises Only**: No consideration for cloud migration
* **Hybrid Approach**: Simultaneous on-premises and cloud development

#### Impact
* Positive: Future-proof architecture with deployment flexibility
* Negative: Additional design complexity
* Risk: Potential rework for cloud-specific optimizations

### 2. Microservices Architecture

#### Decision
Maintain monolithic database-centric architecture for current implementation.

#### Rationale
* Simpler deployment and management
* Better transactional consistency
* Reduced operational complexity
* Appropriate for current scale and requirements

#### Alternatives Considered
* **Microservices**: Decomposed service architecture
* **Service-Oriented Architecture**: Loosely coupled services
* **Serverless Functions**: Event-driven micro-functions

#### Impact
* Positive: Simplified development and deployment
* Negative: Less flexibility for independent scaling
* Risk: Potential bottlenecks in future growth

## Conclusion
These design decisions reflect a balanced approach to building a robust, secure, and maintainable Customer Loyalty Points & Rewards Automation System. Each decision considers multiple factors including functionality, performance, security, and maintainability. The documented rationale enables future developers to understand the reasoning behind architectural choices and make informed decisions about potential modifications or enhancements.