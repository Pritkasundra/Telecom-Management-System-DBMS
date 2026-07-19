-- Subscriber self-reference (referral chain lookups)
CREATE INDEX idx_subscriber_referred_by
    ON Subscriber (Referred_by);

-- Complain table FK
CREATE INDEX idx_complaint_subscriber_id
    ON Complaint (Subscriber_id);

-- Sim_card FKs (most queried table — joins to Subscriber constantly)
CREATE INDEX idx_simcard_subscriber_id
    ON Sim_card (Subscriber_id);

-- Portability_request FK
CREATE INDEX idx_portreq_sim_id
    ON Portability_request (Sim_id);

-- Sim_plan FKs 
CREATE INDEX idx_simplan_sim_id
    ON Sim_plan (Sim_id);

CREATE INDEX idx_simplan_plan_id
    ON Sim_plan (Plan_id);


CREATE INDEX idx_datausage_sim_id
    ON Data_usage (Sim_id);

-- Sim_tower / Tower_connection FKs
CREATE INDEX idx_towerconn_sim_id
    ON Tower_connection (Sim_id);

CREATE INDEX idx_towerconn_tower_id
    ON Tower_connection (Tower_id);

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


-- Frequently filter bills by status ('unpaid', 'overdue')
CREATE INDEX idx_bill_status
    ON Bill (Bill_status);

-- Frequently filter payments by status
CREATE INDEX idx_payment_status
    ON Payment (Payment_status);

-- Call records are commonly filtered/sorted by date
CREATE INDEX idx_callrecord_date
    ON Call_Record (Date_and_time);

-- Recharge reports often filter by date range
CREATE INDEX idx_recharge_date
    ON Recharge (Recharge_Date);
