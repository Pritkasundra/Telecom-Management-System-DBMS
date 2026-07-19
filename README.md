# Telecom Database Project

A schema for a telecom service provider platform (like Jio/Airtel/Vi) — subscribers, SIM cards, service plans, recharges, billing, payments, and network usage, with indexing, views, and analytics queries.

## Files

| File | What's in it |
|---|---|
| `Telecom_ER_diagram.png` | ER diagram of the whole schema |
| `DDL.sql` | tables ( partitioned) |
| `Index.sql` | 17 indexes for common queries |
| `Views.sql` | 4 reporting views |
| `Analytic_queries.sql` | 10 business analytics queries |

## Structure

- **Subscriber side:** subscriber, address, portability_request, complain
- **Plans & Offers:** service_plan, offer, benefit
- **SIM & Devices:** sim_card, device, cell_tower, tower_connection
- **Usage:** call_record, sms, data_usage
- **Billing & Payments:** recharge, bill, payment
