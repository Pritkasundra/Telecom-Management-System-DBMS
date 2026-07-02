-- ================================================================
--  INDEXING SCRIPT — NETWORK MANAGEMENT SYSTEM (PostgreSQL)
--  Run this in pgAdmin Query Tool AFTER your DDL/tables are created
-- ================================================================

-- NOTE: PostgreSQL automatically creates indexes for:
--   1. PRIMARY KEY columns
--   2. UNIQUE constraint columns
-- You do NOT need to manually index these again.
-- Below we ONLY index Foreign Keys and frequently filtered columns.


-- ───────────────────────────────────────────────
-- 1. FOREIGN KEY INDEXES
--    Why: Postgres does NOT auto-index FKs. Every JOIN on these
--    columns will do a full table scan unless indexed.
-- ───────────────────────────────────────────────

-- Subscriber self-reference (referral chain lookups)
CREATE INDEX idx_subscriber_referred_by
    ON Subscriber (Referred_by);

-- Email table FK
CREATE INDEX idx_email_subscriber_id
    ON Email (Subscriber_id);

-- Complain table FK
CREATE INDEX idx_complaint_subscriber_id
    ON Complaint (Subscriber_id);

-- Sim_card FKs (most queried table — joins to Subscriber constantly)
CREATE INDEX idx_simcard_subscriber_id
    ON Sim_card (Subscriber_id);

CREATE INDEX idx_simcard_replace_by
    ON Sim_card (Replace_by);

-- Portability_request FK
CREATE INDEX idx_portreq_sim_id
    ON Portability_request (Sim_id);

-- Sim_plan FKs (heavily joined — Sim_card <-> Service_plan)
CREATE INDEX idx_simplan_sim_id
    ON Sim_plan (Sim_id);

CREATE INDEX idx_simplan_plan_id
    ON Sim_plan (Plan_id);

-- SMS FK
CREATE INDEX idx_sms_sim_id
    ON SMS (Sim_id);

-- Data_usage FK (already has Sim_id in composite PK, but a
-- standalone index helps when querying by Sim_id alone without Date)
CREATE INDEX idx_datausage_sim_id
    ON Data_usage (Sim_id);

-- Call_Record FK (this table grows fastest — index is critical)
CREATE INDEX idx_callrecord_sim_id
    ON Call_Record (Sim_id);

-- Sim_tower / Tower_connection FKs
CREATE INDEX idx_towerconn_sim_id
    ON Tower_connection (Sim_id);

CREATE INDEX idx_towerconn_tower_id
    ON Tower_connection (Tower_id);

-- SIM_Device FKs
CREATE INDEX idx_simdevice_sim_id
    ON SIM_Device (Sim_id);

CREATE INDEX idx_simdevice_imei_no
    ON SIM_Device (IMEI_no);

-- Recharge FKs
CREATE INDEX idx_recharge_simplan_id
    ON Recharge (Sim_plan_id);

CREATE INDEX idx_recharge_transaction_id
    ON Recharge (Transaction_id);

-- Bill FKs
CREATE INDEX idx_bill_simplan_id
    ON Bill (Sim_plan_id);

CREATE INDEX idx_bill_transaction_id
    ON Bill (Transaction_id);

-- Service_plan_offer & Plan_benifit already have composite PKs
-- (Plan_id, Offer_id) and (Plan_id, benefit_id) which Postgres
-- auto-indexes — no extra index needed there.


-- ───────────────────────────────────────────────
-- 2. QUERY-PATTERN INDEXES
--    Why: Columns frequently used in WHERE / ORDER BY that are
--    NOT primary keys or FKs, but appear often in reports.
-- ───────────────────────────────────────────────

-- Frequently filter SIMs by status ('active', 'blocked', etc.)
CREATE INDEX idx_simcard_status
    ON Sim_card (Sim_status);

-- Frequently filter bills by status ('unpaid', 'overdue')
CREATE INDEX idx_bill_status
    ON Bill (Bill_status);

-- Frequently filter payments by status
CREATE INDEX idx_payment_status
    ON Payment (Payment_status);

-- Frequently filter/report complaints with NULL resolution_date
-- (a PARTIAL index — only indexes unresolved rows, very efficient)
CREATE INDEX idx_complain_unresolved
    ON Complain (Subscriber_id)
    WHERE Resolution_date IS NULL;

-- Call records are commonly filtered/sorted by date
CREATE INDEX idx_callrecord_date
    ON Call_Record (Date_and_time);

-- Recharge reports often filter by date range
CREATE INDEX idx_recharge_date
    ON Recharge (Recharge_Date);


-- ───────────────────────────────────────────────
-- 3. COMPOSITE INDEX EXAMPLE
--    Why: When two columns are ALWAYS queried together,
--    a single composite index is faster than two separate ones.
-- ───────────────────────────────────────────────

-- Example: Querying "active plan for this specific SIM" is common
CREATE INDEX idx_simplan_sim_status
    ON Sim_plan (Sim_id, Status);

CREATE INDEX IF NOT EXISTS idx_sim_replace
    ON sim_card(Replace_by)
    WHERE Replace_by IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_call_sim
    ON call_record(Sim_id);

-- Before index: look for "Seq Scan" in the output (slow, full table read)
-- After index:  look for "Index Scan" in the output (fast, direct lookup)

-- ================================================================
-- END OF INDEXING SCRIPT
-- ================================================================
