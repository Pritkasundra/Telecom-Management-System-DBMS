-- 1. Subscriber SIM & Plan Details
CREATE VIEW subscriber_sim_plan_details AS
SELECT
    s.subscriber_id,
    s.name AS subscriber_name,
    sc.sim_id,
    sc.mobile_no,
    sc.sim_status,
    sp.plan_id,
    sp.plan_name,
    sp.plan_category,
    sp.charge AS plan_charge,
    st.start_date,
    st.end_date,
    st.status AS subscription_status
FROM subscriber s
JOIN sim_card sc
    ON s.subscriber_id = sc.subscriber_id
JOIN sim_plan spc
    ON sc.sim_id = spc.sim_id
JOIN service_plan sp
    ON spc.plan_id = sp.plan_id;


-- 2. Tower Activity Summary
CREATE VIEW tower_activity_summary AS
SELECT
    ct.tower_id,
    ct.location,
    ct.coverage_area,
    ct.tower_status,
    COUNT(DISTINCT tc.sim_id) AS unique_sims,
    AVG(tc.signal_strength) AS avg_signal_strength
FROM cell_tower ct
LEFT JOIN tower_connection tc
    ON ct.tower_id = tc.tower_id
GROUP BY
    ct.tower_id,
    ct.location,
    ct.coverage_area,
    ct.tower_status;


-- 3. Pending Complaints
CREATE VIEW pending_complaints AS
SELECT
    c.complaint_id,
    c.complaint_date,
    c.complaint_type,
    c.description,
    c.complaint_status,
    s.subscriber_id,
    s.name AS subscriber_name
FROM complaint c
JOIN subscriber s
    ON c.subscriber_id = s.subscriber_id
WHERE c.Resolution_date IS NULL;  


-- 4. Pending Bills
CREATE VIEW pending_bills AS
SELECT
    b.bill_id,
    sp.sim_id,
    b.bill_date,
    b.due_date,
    b.call_charge,
    b.sms_charge,
    b.data_charge,
    b.gst,
    b.bill_status
FROM bill b
JOIN sim_plan sp
    ON b.sim_plan_id = sp.sim_plan_id
WHERE b.bill_status = 'Pending';
