-- 1. TRIGGER FOR AUTOMATIC BILL STATUS UPDATE
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
CREATE TRIGGER Set_Plan_End_Date
BEFORE INSERT ON SIM_Plan
FOR EACH ROW
BEGIN
    DECLARE v_validity INT;
    
    SELECT validity_days INTO v_validity
    FROM Service_plan
    WHERE plan_id = NEW.plan_id;
    
    SET NEW.end_date = DATE_ADD(NEW.start_date, INTERVAL v_validity DAY);
    SET NEW.is_current = 'yes';
END;
