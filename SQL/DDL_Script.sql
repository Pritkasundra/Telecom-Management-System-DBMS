-- ============================================================
-- NETWORK MANAGEMENT SYSTEM — FULL DDL SCRIPT (CORRECTED)
-- Datatypes corrected based on sample data values
-- ============================================================

-- Drop tables in reverse FK dependency order (safe re-run)
DROP TABLE IF EXISTS Tower_Connection;
DROP TABLE IF EXISTS Sim_tower;
DROP TABLE IF EXISTS SIM_Device;
DROP TABLE IF EXISTS Call_Record;
DROP TABLE IF EXISTS SMS;
DROP TABLE IF EXISTS Data_usage;
DROP TABLE IF EXISTS Complaint;
DROP TABLE IF EXISTS Portability_request;
DROP TABLE IF EXISTS Payment;
DROP TABLE IF EXISTS Bill;
DROP TABLE IF EXISTS Recharge;
DROP TABLE IF EXISTS Sim_plan;
DROP TABLE IF EXISTS Service_plan_offer;
DROP TABLE IF EXISTS Plan_benifit;
DROP TABLE IF EXISTS Sim_card;
DROP TABLE IF EXISTS Device;
DROP TABLE IF EXISTS Call_tower;
DROP TABLE IF EXISTS Service_plan;
DROP TABLE IF EXISTS Offer;
DROP TABLE IF EXISTS Benifit;
DROP TABLE IF EXISTS Email;
DROP TABLE IF EXISTS Subscriber;

-- ============================================================
-- 1. SUBSCRIBER
-- FIX: Subscriber_id → VARCHAR(10)  (sample: SUB000001)
--      Referred_by   → VARCHAR(10)  (sample: SUB033521)
-- ============================================================
CREATE TABLE Subscriber (
    Subscriber_id   VARCHAR(10)     PRIMARY KEY,
    Referred_by     VARCHAR(10)     NULL,           -- self-referencing FK
    First_name      VARCHAR(50)     NOT NULL,
    Last_name       VARCHAR(50)     NOT NULL,
    DOB             DATE            NOT NULL,
    ID_proof        VARCHAR(100)    NOT NULL,
    Registration_date TIMESTAMP     NOT NULL,
    House_no        VARCHAR(20),
    Street          VARCHAR(100),
    Pincode         VARCHAR(10),
    City            VARCHAR(50),

    CONSTRAINT fk_subscriber_referral
        FOREIGN KEY (Referred_by) REFERENCES Subscriber(Subscriber_id)
);

-- ============================================================
-- 2. EMAIL  (multi-valued attribute → separate table)
-- FIX: Subscriber_id → VARCHAR(10)
-- ============================================================
CREATE TABLE Email (
    Subscriber_id   VARCHAR(10)     NOT NULL,
    Email           VARCHAR(150)    NOT NULL,

    PRIMARY KEY (Subscriber_id, Email),

    CONSTRAINT fk_email_subscriber
        FOREIGN KEY (Subscriber_id) REFERENCES Subscriber(Subscriber_id)
        ON DELETE CASCADE
);

-- ============================================================
-- 3. OFFER
-- FIX: Offer_id → VARCHAR(10)  (sample: OFF000001)
-- ============================================================
CREATE TABLE Offer (
    Offer_id            VARCHAR(10)     PRIMARY KEY,
    offer_name          VARCHAR(100)    NOT NULL,
    offer_type          VARCHAR(50),  
    value_unit          VARCHAR(50),
);

-- ============================================================
-- 4. SERVICE_PLAN
-- FIX: Plan_id → VARCHAR(10)  (sample: PLN000001)
-- ============================================================
CREATE TABLE Service_plan (
    Plan_id         VARCHAR(10)     PRIMARY KEY,
    Plan_name       VARCHAR(100)    NOT NULL,
    Plan_type   VARCHAR(50),
    Voice_limit     INT,            -- in minutes
    SMS_limit       INT,
    Data_limit      DECIMAL(10,2),  -- in MB
    Validity_days   INT,
    Charge          DECIMAL(10,2)   NOT NULL
);

-- ============================================================
-- 5. SERVICE_PLAN_OFFER  (M:N junction — Service_plan ↔ Offer)
-- FIX: Plan_id → VARCHAR(10), Offer_id → VARCHAR(10)
-- ============================================================
CREATE TABLE Service_plan_offer (
    Plan_id         VARCHAR(10)     NOT NULL,
    Offer_id        VARCHAR(10)     NOT NULL,
    start_date          TIMESTAMP,
    end_date            TIMESTAMP,
    Offer_value         DECIMAL(5,2)  

    PRIMARY KEY (Plan_id, Offer_id),

    CONSTRAINT fk_spo_plan
        FOREIGN KEY (Plan_id)  REFERENCES Service_plan(Plan_id),
    CONSTRAINT fk_spo_offer
        FOREIGN KEY (Offer_id) REFERENCES Offer(Offer_id)
);

-- ============================================================
-- 6. BENIFIT
-- FIX: benefit_id → VARCHAR(10)  (sample: BEN000001)
-- ============================================================
CREATE TABLE Benifit (
    benefit_id          VARCHAR(10)     PRIMARY KEY,
    benefit_name        VARCHAR(100)    NOT NULL,
    benefit_type        VARCHAR(50),
    benefit_provider    VARCHAR(100)
);

-- ============================================================
-- 7. PLAN_BENIFIT  (M:N junction — Service_plan ↔ Benifit)
-- FIX: Plan_id → VARCHAR(10), benefit_id → VARCHAR(10)
-- ============================================================
CREATE TABLE Plan_benifit (
    Plan_id         VARCHAR(10)     NOT NULL,
    benefit_id      VARCHAR(10)     NOT NULL,
    start_date          TIMESTAMP,
    end_date            TIMESTAMP,  
    terms_condition TEXT,

    PRIMARY KEY (Plan_id, benefit_id),

    CONSTRAINT fk_pb_plan
        FOREIGN KEY (Plan_id)    REFERENCES Service_plan(Plan_id),
    CONSTRAINT fk_pb_benefit
        FOREIGN KEY (benefit_id) REFERENCES Benifit(benefit_id)
);

-- ============================================================
-- 8. DEVICE
-- No datatype changes needed (IMEI_no already VARCHAR(20))
-- ============================================================
CREATE TABLE Device (
    IMEI_no             VARCHAR(20)     PRIMARY KEY,
    Device_brand        VARCHAR(50),
    Device_type         VARCHAR(50),
    Device_model        VARCHAR(100),
    Device_status       VARCHAR(20)     DEFAULT 'active',
    Registration_date   TIMESTAMP
);

-- ============================================================
-- 9. CALL_TOWER
-- No datatype changes needed (Tower_id values are plain integers)
-- ============================================================
CREATE TABLE Call_tower (
    Tower_id        INT             PRIMARY KEY,
    capacity        INT,
    covrage_area    VARCHAR(100),
    location        VARCHAR(200),
    Tower_status    VARCHAR(20)     DEFAULT 'active'
);

-- ============================================================
-- 10. SIM_CARD
-- FIX: Sim_id      → VARCHAR(10)  (sample: SIM000001)
--      Subscriber_id → VARCHAR(10)
--      Replace_by  → VARCHAR(10)
-- ============================================================
CREATE TABLE Sim_card (
    Sim_id          VARCHAR(10)     PRIMARY KEY,
    Subscriber_id   VARCHAR(10)     NOT NULL,
    Replace_by      VARCHAR(10)     NULL,           -- self-referencing FK
    Mobile_no       VARCHAR(15)     NOT NULL UNIQUE,
    Sim_status      VARCHAR(20)     DEFAULT 'active',
    Sim_category    VARCHAR(20),                    -- prepaid / postpaid
    Activation_date TIMESTAMP
);

ALTER TABLE Sim_card
    ADD CONSTRAINT fk_sim_subscriber
        FOREIGN KEY (Subscriber_id) REFERENCES Subscriber(Subscriber_id),
    ADD CONSTRAINT fk_sim_replace
        FOREIGN KEY (Replace_by)    REFERENCES Sim_card(Sim_id);

-- ============================================================
-- 11. SIM_PLAN  (M:N junction — Sim_card ↔ Service_plan)
-- FIX: Sim_plan_id → VARCHAR(10)  (sample: SPL000001)
--      Sim_id      → VARCHAR(10)
--      Plan_id     → VARCHAR(10)
-- ============================================================
CREATE TABLE Sim_plan (
    Sim_plan_id     VARCHAR(10)     PRIMARY KEY,
    Sim_id          VARCHAR(10)     NOT NULL,
    Plan_id         VARCHAR(10)     NOT NULL,
    start_date      TIMESTAMP,
    end_date        TIMESTAMP,

    CONSTRAINT fk_simplan_sim
        FOREIGN KEY (Sim_id)  REFERENCES Sim_card(Sim_id),
    CONSTRAINT fk_simplan_plan
        FOREIGN KEY (Plan_id) REFERENCES Service_plan(Plan_id)
);

-- ============================================================
-- 12. PORTABILITY_REQUEST
-- FIX: Port_id → VARCHAR(10)  (sample: PORT000001)
--      Sim_id   → VARCHAR(10)
-- ============================================================
CREATE TABLE Portability_request (
    Port_id             VARCHAR(10)     PRIMARY KEY,
    Sim_id              VARCHAR(10)     NOT NULL,
    request_date        TIMESTAMP,
    completion_date     TIMESTAMP,
    new_operator        VARCHAR(100),
    Reason              TEXT,
    Status              VARCHAR(20) NOT NULL
    CHECK (Status IN (
            'Pending',
            'Approved',
            'Rejected',
            'Completed',
            'Cancelled'
        )),

    CONSTRAINT fk_port_sim
        FOREIGN KEY (Sim_id) REFERENCES Sim_card(Sim_id)
);

-- ============================================================
-- 13. COMPLAINT
-- FIX: Complaint_id  → VARCHAR(10)  (sample: CMP000001)
--      Subscriber_id → VARCHAR(10)
-- ============================================================
CREATE TABLE Complaint (
    Complaint_id        VARCHAR(10)     PRIMARY KEY,
    Subscriber_id       VARCHAR(10)     NOT NULL,
    Complaint_date      TIMESTAMP,
    Resolution_date     TIMESTAMP,
    description         TEXT,
    Complaint_type      VARCHAR(50),

    CONSTRAINT fk_complaint_subscriber
        FOREIGN KEY (Subscriber_id) REFERENCES Subscriber(Subscriber_id)
);

-- ============================================================
-- 14. SMS
-- FIX: SMS_id → VARCHAR(10)  (sample: SMS0000001)
--      Sim_id  → VARCHAR(10)
-- ============================================================
CREATE TABLE SMS (
    SMS_id          VARCHAR(10)     PRIMARY KEY,
    Sim_id          VARCHAR(10)     NOT NULL,
    Date_and_time   TIMESTAMP,
    Charge          DECIMAL(8,2),
    Direcation_SMS  VARCHAR(10),    -- 'sent' / 'received'
    Other_phone_no  VARCHAR(15),

    CONSTRAINT fk_sms_sim
        FOREIGN KEY (Sim_id) REFERENCES Sim_card(Sim_id)
);

-- ============================================================
-- 15. DATA_USAGE
-- FIX: Sim_id → VARCHAR(10)
-- ============================================================
CREATE TABLE Data_usage (
    Date        DATE        NOT NULL,
    Sim_id      VARCHAR(10) NOT NULL,
    Data_usage  DECIMAL(12,4),      -- in MB

    PRIMARY KEY (Date, Sim_id),

    CONSTRAINT fk_datausage_sim
        FOREIGN KEY (Sim_id) REFERENCES Sim_card(Sim_id)
);

-- ============================================================
-- 16. CALL_RECORD
-- FIX: call_id → VARCHAR(12)  (sample: CALL0000001)
--      Sim_id   → VARCHAR(10)
-- ============================================================
CREATE TABLE Call_Record (
    call_id         VARCHAR(12)     PRIMARY KEY,
    Sim_id          VARCHAR(10)     NOT NULL,
    other_phone_no  VARCHAR(15),
    Duration        INT,            -- in seconds
    call_type       VARCHAR(20),    -- 'incoming' / 'outgoing'
    call_cost       DECIMAL(8,2),
    Date_and_time   TIMESTAMP,
    Call_direction  VARCHAR(10)

    CONSTRAINT fk_callrec_sim
        FOREIGN KEY (Sim_id) REFERENCES Sim_card(Sim_id)
);

-- ============================================================
-- 17. SIM_DEVICE  (M:N junction — Sim_card ↔ Device)
-- FIX: Sim_id → VARCHAR(10)
-- ============================================================
CREATE TABLE SIM_Device (
    Sim_id      VARCHAR(10)     NOT NULL,
    IMEI_no     VARCHAR(20)     NOT NULL,
    Start_date  TIMESTAMP,
    end_date    TIMESTAMP,

    PRIMARY KEY (Sim_id, IMEI_no),

    CONSTRAINT fk_simdev_sim
        FOREIGN KEY (Sim_id)  REFERENCES Sim_card(Sim_id),
    CONSTRAINT fk_simdev_device
        FOREIGN KEY (IMEI_no) REFERENCES Device(IMEI_no)
);

-- ============================================================
-- 19. TOWER_CONNECTION
-- FIX: Sim_id → VARCHAR(10)
--      Tower_id stays INT (plain integer values in sample data)
-- ============================================================
CREATE TABLE Tower_Connection (
    Connection_id       INT             PRIMARY KEY,
    Sim_id              VARCHAR(10)     NOT NULL,
    Tower_id            INT             NOT NULL,
    Connect_time        TIMESTAMP,
    Disconnect_time     TIMESTAMP,
    Signal_strength     DECIMAL(6,2),   -- in dBm

    CONSTRAINT fk_tc_sim
        FOREIGN KEY (Sim_id)   REFERENCES Sim_card(Sim_id),
    CONSTRAINT fk_tc_tower
        FOREIGN KEY (Tower_id) REFERENCES Call_tower(Tower_id)
);

-- ============================================================
-- 20. PAYMENT
-- FIX: Transaction_id → VARCHAR(12)  (sample: TXN0000001)
-- ============================================================
CREATE TABLE Payment (
    Transaction_id  VARCHAR(12)     PRIMARY KEY,
    Payment_amount  DECIMAL(12,2)   NOT NULL,
    Payment_method  VARCHAR(50),
    Payment_date    TIMESTAMP,
    Payment_status  VARCHAR(20)     DEFAULT 'pending',
    Payment_for     VARCHAR(20)     CHECK (Payment_for IN ('recharge', 'bill'))
);

-- ============================================================
-- 21. RECHARGE
-- FIX: Recharge_id    → VARCHAR(10)  (sample: REC000001)
--      Sim_plan_id    → VARCHAR(10)
--      Transaction_id → VARCHAR(12)
-- ============================================================
CREATE TABLE Recharge (
    Recharge_id     VARCHAR(10)     PRIMARY KEY,
    Sim_plan_id     VARCHAR(10)     NOT NULL,
    Transaction_id  VARCHAR(12)     NOT NULL UNIQUE, -- 1:1 with Payment
    GST             DECIMAL(10,2),
    Recharge_amount DECIMAL(10,2),
    Recharge_status VARCHAR(20)     DEFAULT 'success',
    Recharge_Date   TIMESTAMP,

    CONSTRAINT fk_recharge_simplan
        FOREIGN KEY (Sim_plan_id)    REFERENCES Sim_plan(Sim_plan_id),
    CONSTRAINT fk_recharge_payment
        FOREIGN KEY (Transaction_id) REFERENCES Payment(Transaction_id)
);

-- ============================================================
-- 22. BILL
-- FIX: Bill_id       → VARCHAR(10)  (sample: BILL000001)
--      Transaction_id → VARCHAR(12)
--      Sim_plan_id    → VARCHAR(10)
-- ============================================================
CREATE TABLE Bill (
    Bill_id         VARCHAR(10)     PRIMARY KEY,
    Transaction_id  VARCHAR(12)     NOT NULL UNIQUE, -- 1:1 with Payment
    Sim_plan_id     VARCHAR(10)     NOT NULL UNIQUE, -- 1:1 with Sim_plan
    Bill_status     VARCHAR(20)     DEFAULT 'unpaid',
    SMS_charge      DECIMAL(10,2),
    call_charge     DECIMAL(10,2),
    Data_charge     DECIMAL(10,2),
    GST             DECIMAL(10,2),
    Bill_date       TIMESTAMP,
    Due_date        TIMESTAMP,

    CONSTRAINT fk_bill_payment
        FOREIGN KEY (Transaction_id) REFERENCES Payment(Transaction_id),
    CONSTRAINT fk_bill_simplan
        FOREIGN KEY (Sim_plan_id) REFERENCES Sim_plan(Sim_plan_id)
);

-- ============================================================
-- END OF DDL
-- Total tables: 22
-- ============================================================
