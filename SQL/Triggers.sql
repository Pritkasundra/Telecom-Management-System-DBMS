-- 1. TRIGGER FOR AUTOMATIC BILL STATUS UPDATE
--    Why: Ensures that when a payment is made for a bill, the bill's status is automatically updated to 'paid' without needing manual intervention.
CREATE TRIGGER Update_Bill_After_Payment
AFTER INSERT ON Payment
FOR EACH ROW
BEGIN
    IF NEW.payment_for = 'bill' THEN
        UPDATE Bill
        SET bill_status = 'paid'
        WHERE transaction_id = NEW.transaction_id;
    END IF;
END;

--2. TRIGGER FOR AUTOMATIC RECHARGE STATUS UPDATE
--    Why: Ensures that when a payment is made for a recharge, the recharge's status is automatically updated to 'success', reflecting the successful recharge in the system without manual updates.
CREATE TRIGGER Update_Recharge_After_Payment
AFTER INSERT ON Payment
FOR EACH ROW
BEGIN
    IF NEW.payment_for = 'recharge' THEN
        UPDATE Recharge
        SET recharge_status = 'success'
        WHERE transaction_id = NEW.transaction_id;
    END IF;
END;

--3. TRIGGER FOR AUTOMATIC SIM PLAN END DATE CALCULATION
--    Why: Automatically calculates the end date of a SIM plan based on its start date and the validity period
CREATE TRIGGER Set_Plan_End_Date
BEFORE INSERT ON SIM_Plan
FOR EACH ROW
BEGIN
    DECLARE v_validity INT;
    
    -- get validity_days from Service_plan
    SELECT validity_days INTO v_validity
    FROM Service_plan
    WHERE plan_id = NEW.plan_id;
    
    -- calculate end_date automatically
    SET NEW.end_date = DATE_ADD(NEW.start_date, INTERVAL v_validity DAY);
    SET NEW.is_current = 'yes';
END;

-- 4. EVENT SCHEDULER FOR EXPIRE SIM PLANS
--    Why: Automatically marks SIM plans as expired when their end date has passed
CREATE EVENT Expire_SIM_Plans
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    UPDATE SIM_Plan
    SET is_current = 'no'
    WHERE end_date < CURRENT_DATE
    AND is_current = 'yes';
END;