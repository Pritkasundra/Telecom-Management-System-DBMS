-- ============================================================
-- TELECOM NETWORK MANAGEMENT SYSTEM
-- EXPLAIN ANALYZE — BEFORE & AFTER INDEXING


-- ── Q1: Find all active SIM cards for a specific subscriber ──
-- Tests: FK lookup subscriber→sim_card (Seq Scan expected before index)
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT sc.Sim_id, sc.Mobile_no, sc.Sim_category, sc.Sim_status, sc.Activation_date
FROM   sim_card sc
WHERE  sc.Subscriber_id = 'SUB023456';

-- ── Q2: Monthly revenue from successful recharges ────────────
-- Tests: full scan on recharge + payment join, GROUP BY month
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT DATE_TRUNC('month', r.Recharge_Date) AS month,
       COUNT(*)                              AS total_recharges,
       SUM(r.Recharge_amount)               AS gross_revenue,
       SUM(r.GST)                           AS total_gst
FROM   recharge r
JOIN   payment  p ON p.Transaction_id = r.Transaction_id
WHERE  p.Payment_status = 'success'
GROUP  BY 1
ORDER  BY 1;

-- ── Q3: Top 10 subscribers by total call duration ────────────
-- Tests: call_record full scan + sim_card join + aggregation
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT s.Subscriber_id,
       s.First_name || ' ' || s.Last_name AS full_name,
       SUM(cr.Duration)                   AS total_seconds,
       COUNT(cr.call_id)                  AS call_count
FROM   call_record cr
JOIN   sim_card    sc ON sc.Sim_id        = cr.Sim_id
JOIN   subscriber  s  ON s.Subscriber_id  = sc.Subscriber_id
WHERE  cr.call_type = 'outgoing'
GROUP  BY s.Subscriber_id, s.First_name, s.Last_name
ORDER  BY total_seconds DESC
LIMIT  10;

-- ── Q4: SIMs with no recharge in the last 90 days ────────────
-- Tests: NOT EXISTS anti-join pattern; date filter on recharge
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT sc.Sim_id, sc.Mobile_no, sc.Sim_category, sc.Activation_date
FROM   sim_card sc
WHERE  sc.Sim_status = 'active'
  AND  NOT EXISTS (
           SELECT 1
           FROM   sim_plan  sp
           JOIN   recharge  r ON r.Sim_plan_id = sp.Sim_plan_id
           WHERE  sp.Sim_id       = sc.Sim_id
             AND  r.Recharge_Date >= NOW() - INTERVAL '90 days'
       );

-- ── Q5: Daily data consumption per city (last 30 days) ───────
-- Tests: data_usage → sim_card → subscriber join + city group
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT sub.City,
       du.Date,
       COUNT(DISTINCT du.Sim_id) AS active_sims,
       SUM(du.Data_usage)        AS total_mb,
       AVG(du.Data_usage)        AS avg_mb_per_sim
FROM   data_usage  du
JOIN   sim_card    sc  ON sc.Sim_id       = du.Sim_id
JOIN   subscriber  sub ON sub.Subscriber_id = sc.Subscriber_id
WHERE  du.Date >= CURRENT_DATE - INTERVAL '30 days'
GROUP  BY sub.City, du.Date
ORDER  BY du.Date DESC, total_mb DESC;

-- ── Q6: Complaint resolution SLA — avg days to resolve ───────
-- Tests: filter + date arithmetic + group by complaint type
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT Complaint_type,
       COUNT(*)                                          AS total,
       COUNT(Resolution_date)                            AS resolved,
       ROUND(AVG(EXTRACT(EPOCH FROM (Resolution_date::TIMESTAMP
             - Complaint_date)) / 86400)::NUMERIC, 2)   AS avg_days_to_resolve,
       COUNT(*) FILTER (WHERE Resolution_date IS NULL)  AS still_open
FROM   complaint
GROUP  BY Complaint_type
ORDER  BY avg_days_to_resolve DESC;

-- ── Q7: Bills overdue with subscriber contact details ────────
-- Tests: bill → sim_plan → sim_card → subscriber multi-join
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT b.Bill_id,
       s.First_name || ' ' || s.Last_name AS customer,
       sc.Mobile_no,
       s.City,
       b.Bill_date,
       b.Due_date,
       (b.SMS_charge + b.call_charge + b.Data_charge + b.GST) AS total_amount
FROM   bill       b
JOIN   sim_plan   sp ON sp.Sim_plan_id  = b.Sim_plan_id
JOIN   sim_card   sc ON sc.Sim_id       = sp.Sim_id
JOIN   subscriber s  ON s.Subscriber_id = sc.Subscriber_id
WHERE  b.Bill_status = 'overdue'
ORDER  BY b.Due_date ASC
LIMIT  500;

-- ── Q8: Tower utilisation — avg simultaneous connections ─────
-- Tests: tower_connection range scan + tower join + aggregation
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT ct.Tower_id,
       ct.location,
       ct.covrage_area,
       ct.capacity,
       COUNT(tc.Connection_id)              AS total_connections,
       ROUND(AVG(EXTRACT(EPOCH FROM
             (tc.Disconnect_time - tc.Connect_time))/60)::NUMERIC,2)
                                            AS avg_conn_min,
       ROUND(COUNT(tc.Connection_id) * 100.0 / ct.capacity, 2)
                                            AS utilisation_pct
FROM   call_tower       ct
JOIN   tower_connection tc ON tc.Tower_id = ct.Tower_id
WHERE  tc.Connect_time >= NOW() - INTERVAL '7 days'
GROUP  BY ct.Tower_id, ct.location, ct.covrage_area, ct.capacity
ORDER  BY utilisation_pct DESC
LIMIT  20;

-- ── Q9: Portability requests by operator destination ─────────
-- Tests: portability_request scan + date range + group
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT new_operator,
       COUNT(*)                                            AS total_requests,
       COUNT(*) FILTER (WHERE completion_date IS NOT NULL) AS completed,
       COUNT(*) FILTER (WHERE completion_date IS NULL)     AS pending,
       ROUND(AVG(EXTRACT(EPOCH FROM
             (completion_date::TIMESTAMP - request_date::TIMESTAMP)
             ) / 86400)::NUMERIC, 1)                       AS avg_days_to_port
FROM   portability_request
WHERE  request_date >= '2023-01-01'
GROUP  BY new_operator
ORDER  BY total_requests DESC;

-- ── Q10: Heavy data users — top 100 SIMs by monthly usage ───
-- Tests: data_usage aggregation + window function ranking
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT *
FROM (
    SELECT du.Sim_id,
           sc.Mobile_no,
           sub.City,
           DATE_TRUNC('month', du.Date::TIMESTAMP) AS month,
           SUM(du.Data_usage)                       AS total_mb,
           RANK() OVER (
               PARTITION BY DATE_TRUNC('month', du.Date::TIMESTAMP)
               ORDER BY SUM(du.Data_usage) DESC
           ) AS rnk
    FROM   data_usage  du
    JOIN   sim_card    sc  ON sc.Sim_id        = du.Sim_id
    JOIN   subscriber  sub ON sub.Subscriber_id = sc.Subscriber_id
    GROUP  BY du.Sim_id, sc.Mobile_no, sub.City,
              DATE_TRUNC('month', du.Date::TIMESTAMP)
) ranked
WHERE rnk <= 100
ORDER BY month DESC, rnk;

-- ── Q11: SMS volume and charge by direction (sent/received) ──
-- Tests: sms table full scan + category group
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT sc.Sim_category,
       sm.Direcation_SMS,
       DATE_TRUNC('month', sm.Time) AS month,
       COUNT(sm.SMS_id)             AS sms_count,
       SUM(sm.Charge)               AS total_charge,
       AVG(sm.Charge)               AS avg_charge
FROM   sms      sm
JOIN   sim_card sc ON sc.Sim_id = sm.Sim_id
GROUP  BY sc.Sim_category, sm.Direcation_SMS,
          DATE_TRUNC('month', sm.Time)
ORDER  BY month DESC, sms_count DESC;

-- ── Q12: Active plan details for all SIMs in a city ──────────
-- Tests: multi-table join with city predicate (no index on City)
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT sc.Sim_id,
       sc.Mobile_no,
       sc.Sim_category,
       sp.Plan_name,
       sp.Charge,
       sp.Validity_days,
       simp.start_date,
       simp.end_date,
       simp.Status AS plan_status
FROM   subscriber   sub
JOIN   sim_card     sc   ON sc.Subscriber_id = sub.Subscriber_id
JOIN   sim_plan     simp ON simp.Sim_id      = sc.Sim_id
JOIN   service_plan sp   ON sp.Plan_id       = simp.Plan_id
WHERE  sub.City      = 'Ahmedabad'
  AND  simp.Status   = 'active'
ORDER  BY sp.Charge DESC;

-- ── Q13: Referral chain depth & coin rewards ─────────────────
-- Tests: recursive CTE on self-join in subscriber
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
WITH RECURSIVE referral_tree AS (
    -- anchor: subscribers with no referrer
    SELECT Subscriber_id, Referred_by, First_name, Last_name,
           Number_coin, 0 AS depth
    FROM   subscriber
    WHERE  Referred_by IS NULL

    UNION ALL

    SELECT s.Subscriber_id, s.Referred_by, s.First_name, s.Last_name,
           s.Number_coin, rt.depth + 1
    FROM   subscriber    s
    JOIN   referral_tree rt ON rt.Subscriber_id = s.Referred_by
    WHERE  rt.depth < 5   -- guard against infinite loops
)
SELECT depth,
       COUNT(*)          AS subscribers_at_level,
       SUM(Number_coin)  AS total_coins_at_level,
       AVG(Number_coin)  AS avg_coins
FROM   referral_tree
GROUP  BY depth
ORDER  BY depth;

-- ── Q14: Call cost breakdown by plan category & call type ────
-- Tests: call_record → sim_card → sim_plan → service_plan chain
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT sp.Plan_category,
       cr.call_type,
       COUNT(cr.call_id)   AS total_calls,
       SUM(cr.Duration)    AS total_seconds,
       SUM(cr.call_cost)   AS total_revenue,
       AVG(cr.call_cost)   AS avg_cost_per_call,
       MAX(cr.Duration)    AS longest_call_sec
FROM   call_record  cr
JOIN   sim_card     sc   ON sc.Sim_id   = cr.Sim_id
JOIN   sim_plan     simp ON simp.Sim_id = sc.Sim_id
                        AND simp.Status = 'active'
JOIN   service_plan sp   ON sp.Plan_id  = simp.Plan_id
GROUP  BY sp.Plan_category, cr.call_type
ORDER  BY total_revenue DESC;

-- ── Q15: SIM replacement chain audit ─────────────────────────
-- Tests: self-join on sim_card.Replace_by
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT original.Sim_id         AS original_sim,
       original.Mobile_no      AS mobile_no,
       replacement.Sim_id      AS replacement_sim,
       original.Activation_date AS original_activation,
       replacement.Activation_date AS replacement_activation,
       EXTRACT(DAY FROM (replacement.Activation_date::TIMESTAMP
               - original.Activation_date::TIMESTAMP)) AS days_between
FROM   sim_card original
JOIN   sim_card replacement ON replacement.Sim_id = original.Replace_by
ORDER  BY days_between DESC
LIMIT  200;

-- ── Q16: Payment method popularity by amount band ────────────
-- Tests: payment table scan + CASE bucketing + GROUP BY
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT Payment_method,
       CASE
           WHEN Payment_amount <  200 THEN '< ₹200'
           WHEN Payment_amount <  500 THEN '₹200–499'
           WHEN Payment_amount < 1000 THEN '₹500–999'
           ELSE '₹1000+'
       END AS amount_band,
       COUNT(*)                 AS transactions,
       SUM(Payment_amount)      AS total_amount,
       AVG(Payment_amount)      AS avg_amount,
       COUNT(*) FILTER (WHERE Payment_status = 'failed') AS failures
FROM   payment
GROUP  BY Payment_method, amount_band
ORDER  BY Payment_method, amount_band;

-- ── Q17: Signal strength heatmap per coverage area ───────────
-- Tests: tower_connection → call_tower join + aggregation
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT ct.covrage_area,
       COUNT(tc.Connection_id)            AS connections,
       ROUND(AVG(tc.Signal_strength)::NUMERIC, 2) AS avg_signal_dbm,
       MIN(tc.Signal_strength)            AS worst_signal,
       MAX(tc.Signal_strength)            AS best_signal,
       COUNT(*) FILTER (WHERE tc.Signal_strength < -100) AS poor_signal_count,
       COUNT(*) FILTER (WHERE tc.Signal_strength > -70)  AS good_signal_count
FROM   tower_connection tc
JOIN   call_tower       ct ON ct.Tower_id = tc.Tower_id
GROUP  BY ct.covrage_area
ORDER  BY avg_signal_dbm DESC;

-- ── Q18: Subscriber lifetime value (LTV) calculation ─────────
-- Tests: subscriber → sim_card → sim_plan → recharge chain
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT sub.Subscriber_id,
       sub.First_name || ' ' || sub.Last_name AS full_name,
       sub.City,
       COUNT(DISTINCT sc.Sim_id)    AS sim_count,
       COUNT(r.Recharge_id)         AS total_recharges,
       COALESCE(SUM(r.Recharge_amount), 0) AS lifetime_spend,
       MIN(sub.Registration_date)   AS customer_since,
       EXTRACT(DAY FROM
           (NOW() - MIN(sub.Registration_date::TIMESTAMP)
       )) / 30.0                    AS months_as_customer
FROM   subscriber  sub
JOIN   sim_card    sc   ON sc.Subscriber_id = sub.Subscriber_id
JOIN   sim_plan    simp ON simp.Sim_id      = sc.Sim_id
LEFT   JOIN recharge r  ON r.Sim_plan_id    = simp.Sim_plan_id
GROUP  BY sub.Subscriber_id, sub.First_name, sub.Last_name, sub.City
ORDER  BY lifetime_spend DESC
LIMIT  50;

-- ── Q19: Offers availed per plan — discount impact analysis ──
-- Tests: service_plan_offer → offer → service_plan join
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT sp.Plan_name,
       sp.Plan_category,
       sp.Charge                      AS base_price,
       COUNT(spo.Offer_id)            AS offers_linked,
       MAX(o.Discount_percent)        AS max_discount_pct,
       AVG(o.Discount_percent)        AS avg_discount_pct,
       ROUND(sp.Charge * (1 - MAX(o.Discount_percent)/100), 2)
                                      AS best_discounted_price
FROM   service_plan       sp
LEFT   JOIN service_plan_offer spo ON spo.Plan_id  = sp.Plan_id
LEFT   JOIN offer              o   ON o.Offer_id   = spo.Offer_id
                                  AND o.offer_status = 'active'
GROUP  BY sp.Plan_id, sp.Plan_name, sp.Plan_category, sp.Charge
ORDER  BY offers_linked DESC, sp.Charge;

-- ── Q20: Full subscriber 360° view — single customer report ──
-- Tests: all major tables joined; good for query plan complexity
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT sub.Subscriber_id,
       sub.First_name || ' ' || sub.Last_name                AS name,
       sub.City,
       COUNT(DISTINCT sc.Sim_id)                             AS sims,
       COUNT(DISTINCT simp.Sim_plan_id)                      AS plans,
       COALESCE(SUM(r.Recharge_amount), 0)                   AS total_recharged,
       COUNT(DISTINCT cr.call_id)                            AS calls_made,
       COALESCE(SUM(cr.Duration), 0)                         AS call_seconds,
       COUNT(DISTINCT sm.SMS_id)                             AS sms_sent,
       COALESCE(SUM(du.Data_usage), 0)                       AS total_data_mb,
       COUNT(DISTINCT comp.Complaint_id)                     AS complaints,
       COUNT(DISTINCT pr.Port_id)                            AS port_requests
FROM   subscriber         sub
JOIN   sim_card           sc   ON sc.Subscriber_id  = sub.Subscriber_id
LEFT   JOIN sim_plan      simp ON simp.Sim_id        = sc.Sim_id
LEFT   JOIN recharge      r    ON r.Sim_plan_id      = simp.Sim_plan_id
LEFT   JOIN call_record   cr   ON cr.Sim_id          = sc.Sim_id
LEFT   JOIN sms           sm   ON sm.Sim_id          = sc.Sim_id
LEFT   JOIN data_usage    du   ON du.Sim_id          = sc.Sim_id
LEFT   JOIN complaint     comp ON comp.Subscriber_id = sub.Subscriber_id
LEFT   JOIN portability_request pr ON pr.Sim_id      = sc.Sim_id
WHERE  sub.Subscriber_id = 'SUB001000'
GROUP  BY sub.Subscriber_id, sub.First_name, sub.Last_name, sub.City;



-- ============================================================
-- END OF FILE
-- ============================================================
