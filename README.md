# Telecom Management System

## Overview

The Telecom Management System is a database management project designed to model and manage the core operations of a telecom service provider.

The system provides a structured database for managing subscribers, SIM cards, service plans, recharges, billing, payments, offers, benefits, complaints, portability requests, call records, SMS records, data usage, devices, and cell tower connections.

The project focuses on relational database design, ER modeling, normalization, integrity constraints, SQL querying, views, indexing, functions, procedures, and triggers using PostgreSQL.

---

## Objectives

The main objectives of this project are:

- Design a complete database for telecom operations.
- Maintain subscriber and SIM card information.
- Manage prepaid and postpaid service plans.
- Track plan subscription history.
- Store recharge and billing information.
- Maintain payment transaction records.
- Track call, SMS, and data usage.
- Manage offers and plan benefits.
- Handle subscriber complaints and portability requests.
- Maintain SIM replacement history.
- Track SIM usage across different devices.
- Store SIM-to-cell-tower connection history.
- Maintain data consistency using database constraints.
- Improve query performance using indexes.
- Simplify complex queries using database views.
- Automate database operations using functions, procedures, and triggers.

---

## System Modules

### 1. Subscriber Management

The subscriber module stores customer information such as:

- Subscriber ID
- Name
- Date of birth
- Email
- Address
- ID proof
- Registration date
- Referral information

A subscriber can own multiple SIM cards and can refer other subscribers.

---

### 2. SIM Card Management

The SIM card module manages:

- SIM ID
- Mobile number
- SIM category
- SIM status
- Activation date
- Subscriber ownership
- SIM replacement information

Each SIM card belongs to a subscriber and can maintain relationships with service plans, usage records, devices, and cell towers.

---

### 3. Service Plan Management

The service plan module stores telecom plan information such as:

- Plan ID
- Plan name
- Plan category
- Voice limit
- SMS limit
- Data limit
- Charge
- Validity period

A SIM card can subscribe to service plans, and the subscription relationship maintains the subscription start date, end date, and status.

---

### 4. Offer Management

The offer module manages promotional offers available for service plans.

Offer information includes:

- Offer ID
- Offer name
- Offer type
- Start date
- End date

An offer can apply to multiple service plans, and a service plan can have multiple offers.

The relationship between offers and service plans can store the offer value when the value depends on the selected plan.

---

### 5. Benefit Management

The benefit module stores additional benefits provided with telecom plans, such as:

- OTT subscriptions
- Music subscriptions
- Cloud storage
- Additional data benefits
- Partner services

Benefit information includes:

- Benefit ID
- Benefit name
- Benefit type
- Benefit provider

A service plan can include multiple benefits, and the same benefit can be included in multiple plans.

The relationship can maintain:

- Start date
- End date
- Terms and conditions

---

### 6. Recharge Management

The recharge module stores recharge transactions performed for SIM cards.

It maintains information such as:

- Recharge ID
- Recharge date
- Recharge amount
- GST
- Recharge status

A SIM card can have multiple recharge records over time.

---

### 7. Billing Management

The billing module manages bills generated for postpaid SIM cards.

Bill information includes:

- Bill ID
- Bill date
- Billing period
- SMS charge
- Call charge
- Data charge
- GST
- Total amount
- Due date
- Bill status

A SIM card can have multiple bills generated over different billing periods.

---

### 8. Payment Management

The payment module maintains financial transaction details.

It stores:

- Transaction ID
- Payment method
- Payment date
- Payment amount
- Payment status

Payments are associated with recharge transactions or bill settlements.

---

### 9. Call Record Management

The system maintains call history for each SIM card.

Call records include:

- Call ID
- Other phone number
- Call type
- Call direction
- Date and time
- Duration
- Call cost

A SIM card can generate multiple call records.

---

### 10. SMS Record Management

The SMS module maintains messaging activity.

It stores:

- SMS ID
- Other phone number
- SMS direction
- Date and time
- Charge

A SIM card can have multiple SMS records.

---

### 11. Data Usage Management

The data usage module maintains internet usage records for SIM cards.

It stores information such as:

- Usage ID
- Usage date
- Data consumed
- Data charge

A SIM card can generate multiple data usage records.

---

### 12. Complaint Management

Subscribers can file complaints regarding telecom services.

The complaint module maintains:

- Complaint ID
- Complaint date
- Complaint type
- Description
- Complaint status
- Resolution date

A subscriber can file multiple complaints.

---

### 13. Mobile Number Portability Management

The portability module manages requests for transferring mobile services between telecom operators.

It stores:

- Portability request ID
- SIM ID
- Request date
- Completion date
- New operator
- Reason
- Status

The supported request statuses include:

- Pending
- Approved
- Rejected
- Completed
- Cancelled

A SIM card can have multiple portability requests over time.

---

### 14. Device Management

The device module stores information about devices used with SIM cards.

Device information includes:

- IMEI number
- Device brand
- Device model
- Device type
- Registration date
- Device status

The system maintains SIM-device usage history using start and end dates.

This allows the database to determine which SIM card was used in which device during a specific period.

---

### 15. Cell Tower Management

The cell tower module maintains information about telecom towers.

It stores:

- Tower ID
- Location
- Capacity
- Coverage area
- Tower status

The system maintains connection history between SIM cards and cell towers.

The tower connection relationship stores:

- Connection time
- Disconnection time
- Signal strength

This information can be used for network usage analysis and tower performance monitoring.

---

## Database Relationships

Some of the major relationships in the system are:

| Entity 1 | Relationship | Entity 2 | Cardinality |
|----------|--------------|----------|-------------|
| Subscriber | Owns | SIM Card | 1:N |
| Subscriber | Refers | Subscriber | 1:N |
| Subscriber | Files | Complaint | 1:N |
| SIM Card | Subscribes To | Service Plan | M:N |
| Service Plan | Includes | Benefit | M:N |
| Offer | Applies To | Service Plan | M:N |
| SIM Card | Has | Recharge | 1:N |
| SIM Card | Has | Bill | 1:N |
| SIM Card | Generates | Call Record | 1:N |
| SIM Card | Sends | SMS | 1:N |
| SIM Card | Consumes | Data Usage | 1:N |
| SIM Card | Used In | Device | M:N |
| SIM Card | Connects To | Cell Tower | M:N |
| SIM Card | Replaced By | SIM Card | Self-Referencing |
| SIM Card | Initiates | Portability Request | 1:N |
| Recharge | Paid By | Payment | 1:1 |
| Bill | Settled By | Payment | 1:N |

---

## Database Features

The project demonstrates the following DBMS concepts:

### Database Design

- Entity-Relationship Modeling
- Relational Schema Design
- Primary Keys
- Foreign Keys
- Composite Attributes
- Multivalued Attributes
- Self-Referencing Relationships
- One-to-One Relationships
- One-to-Many Relationships
- Many-to-Many Relationships

### SQL Concepts

- DDL Commands
- DML Commands
- Joins
- Subqueries
- Aggregate Functions
- GROUP BY and HAVING
- Common Table Expressions
- Window Functions
- Views
- Indexes
- Functions
- Stored Procedures
- Triggers
- Transactions

### Database Integrity

The database uses constraints such as:

- PRIMARY KEY
- FOREIGN KEY
- UNIQUE
- NOT NULL
- CHECK
- DEFAULT

These constraints help maintain data accuracy and consistency.

---

## Project Structure

```text
Telecom-Management-System-DBMS/
│
├── ER_Diagram/
│   └── Telecom_ER_Diagram
│
├── Relational_Schema/
│   └── Relational_Schema
│
├── SQL/
│   ├── DDL_Script.sql
│   ├── DML_Script.sql
│   ├── Queries.sql
│   ├── Views.sql
│   ├── Indexes.sql
│   ├── Functions.sql
│   ├── Procedures.sql
│   └── Triggers.sql
│
└── README.md
