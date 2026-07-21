-- 1. Revenue per Service Plan, split by Prepaid (Recharge) vs Postpaid (Bill)
SELECT sp.Plan_id, svc.Plan_name, 'Prepaid' AS billing_type,
       SUM(p.Payment_amount) AS revenue
FROM Recharge r
JOIN Payment p ON r.Transaction_id = p.Transaction_id AND p.Payment_status = 'Success'
JOIN Sim_plan sp ON r.Sim_plan_id = sp.Sim_plan_id
JOIN Service_plan svc ON sp.Plan_id = svc.Plan_id
WHERE r.Recharge_Date >= DATE_TRUNC('month', CURRENT_DATE)
GROUP BY sp.Plan_id, svc.Plan_name;


-- 2. SIMs with plans expiring in the next 7 days
SELECT sc.Sim_id, sc.Mobile_no, sub.First_name, sub.Last_name,
       svc.Plan_name, sp.end_date
FROM Sim_plan sp
JOIN Sim_card sc ON sp.Sim_id = sc.Sim_id
JOIN Subscriber sub ON sc.Subscriber_id = sub.Subscriber_id
JOIN Service_plan svc ON sp.Plan_id = svc.Plan_id
WHERE sp.end_date BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '7 days';


-- 3. Inactive SIMs — no tower connection in the last 30 days
SELECT sc.Sim_id, sc.Mobile_no
FROM Sim_card sc
WHERE sc.SIm_status = 'Active'
  AND NOT EXISTS (
      SELECT 1 FROM Tower_Connection tc
      WHERE tc.Sim_id = sc.Sim_id
        AND tc.connect_time >= CURRENT_DATE - INTERVAL '30 days'
  );


-- 4. Top 5 SIMs by data usage this month
SELECT sc.Sim_id, sc.Mobile_no, SUM(du.Data_usage) AS total_data
FROM Sim_card sc
JOIN Data_usage du ON sc.Sim_id = du.Sim_id
WHERE du.Date >= DATE_TRUNC('month', CURRENT_DATE)
GROUP BY sc.Sim_id, sc.Mobile_no
ORDER BY total_data DESC
LIMIT 5;


-- 5. Complaint volume and average resolution time per complaint type
SELECT complaint_type,
       COUNT(*) AS total_complaints,
       AVG(resolution_date - complaint_date) AS avg_resolution_days
FROM complaint
WHERE resolution_date IS NOT NULL
GROUP BY complaint_type
ORDER BY total_complaints DESC;

-- 6 Most Popular Service Plan
SELECT sp.plan_id,
       sv.plan_name,
       COUNT(*) AS total_users
FROM SIM_Plan sp
JOIN Service_Plan sv
ON sp.plan_id = sv.plan_id
GROUP BY sp.plan_id, sv.plan_name
ORDER BY total_users DESC
LIMIT 1;

-- 7 Find subscribers with more than one SIM card
SELECT subscriber_id,
       COUNT(*) AS total_sim_cards
FROM SIM_card
GROUP BY subscriber_id
HAVING COUNT(*) > 1;

-- 8 Find the most frequently connected cell towers
SELECT tower_id,
       COUNT(*) AS total_connections
FROM Tower_Connection
GROUP BY tower_id
ORDER BY total_connections DESC;

-- 9 Find SIM cards that have been used in multiple devices
SELECT sim_id,
       COUNT(DISTINCT imei_no) AS total_devices
FROM SIM_Device
GROUP BY sim_id
HAVING COUNT(DISTINCT imei_no) > 1;

-- 10 Count of Portability requests for each status
SELECT status,
       COUNT(*) AS total_requests
FROM Portability_request
GROUP BY status;
