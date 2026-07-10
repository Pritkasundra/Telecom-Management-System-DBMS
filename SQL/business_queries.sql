-- =========================================================
-- Business Queries — Telecom Network Management System
-- Author: [Your Name]
-- =========================================================

-- 1. Revenue per Service Plan, split by Prepaid (Recharge) vs Postpaid (Bill)
-- Business case: identifies which plans drive the most revenue and by which
-- billing model, informing pricing and marketing decisions.
SELECT sp.Plan_id, svc.Plan_name, 'Prepaid' AS billing_type,
       SUM(p.Payment_amount) AS revenue
FROM Recharge r
JOIN Payment p ON r.Transaction_id = p.Transaction_id AND p.Payment_status = 'Success'
JOIN Sim_plan sp ON r.Sim_plan_id = sp.Sim_plan_id
JOIN Service_plan svc ON sp.Plan_id = svc.Plan_id
JOIN Sim_card sc ON sp.Sim_id = sc.Sim_id AND sc.Sim_category = 'Prepaid'
WHERE r.Recharge_Date >= DATE_TRUNC('month', CURRENT_DATE)
GROUP BY sp.Plan_id, svc.Plan_name;


-- 2. SIMs with plans expiring in the next 7 days
-- Business case: proactive renewal reminders to reduce churn.
SELECT sc.Sim_id, sc.Mobile_no, sub.First_name, sub.Last_name,
       svc.Plan_name, sp.end_date
FROM Sim_plan sp
JOIN Sim_card sc ON sp.Sim_id = sc.Sim_id
JOIN Subscriber sub ON sc.Subscriber_id = sub.Subscriber_id
JOIN Service_plan svc ON sp.Plan_id = svc.Plan_id
WHERE sp.Status = 'active'
  AND sp.end_date BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '7 days';


-- 3. Inactive SIMs — no tower connection in the last 30 days
-- Business case: flags dormant SIMs for deactivation or win-back campaigns.
SELECT sc.Sim_id, sc.Mobile_no
FROM Sim_card sc
WHERE sc.SIm_status = 'Active'
  AND NOT EXISTS (
      SELECT 1 FROM Tower_Connection tc
      WHERE tc.Sim_id = sc.Sim_id
        AND tc.connect_time >= CURRENT_DATE - INTERVAL '30 days'
  );


-- 4. Top 5 SIMs by data usage this month
-- Business case: identifies heavy users for data-plan upsell targeting.
SELECT sc.Sim_id, sc.Mobile_no, SUM(du.Data_usage) AS total_data
FROM Sim_card sc
JOIN Data_usage du ON sc.Sim_id = du.Sim_id
WHERE du.Date >= DATE_TRUNC('month', CURRENT_DATE)
GROUP BY sc.Sim_id, sc.Mobile_no
ORDER BY total_data DESC
LIMIT 5;


-- 5. Complaint volume and average resolution time per complaint type
-- Business case: highlights which complaint categories are frequent/slow
-- to resolve, helping prioritize support staffing.
SELECT complaint_type,
       COUNT(*) AS total_complaints,
       AVG(resolution_date - complaint_date) AS avg_resolution_days
FROM complaint
WHERE resolution_date IS NOT NULL
GROUP BY complaint_type
ORDER BY total_complaints DESC;
