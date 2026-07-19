CREATE TABLE Subscriber (
    Subscriber_id   VARCHAR(10)     PRIMARY KEY,
    Referred_by     VARCHAR(10)     NULL,           
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

CREATE TABLE Email (
    Subscriber_id   VARCHAR(10)     NOT NULL,
    Email           VARCHAR(150)    NOT NULL,

    PRIMARY KEY (Subscriber_id, Email),

    CONSTRAINT fk_email_subscriber
        FOREIGN KEY (Subscriber_id) REFERENCES Subscriber(Subscriber_id)
        ON DELETE CASCADE
);


CREATE TABLE Offer (
    Offer_id            VARCHAR(10)     PRIMARY KEY,
    offer_name          VARCHAR(100)    NOT NULL,
    offer_type          VARCHAR(50),  
    value_unit          VARCHAR(50),
);


CREATE TABLE Service_plan (
    Plan_id         VARCHAR(10)     PRIMARY KEY,
    Plan_name       VARCHAR(100)    NOT NULL,
    Plan_type   VARCHAR(50),
    Voice_limit     INT,           
    SMS_limit       INT,
    Data_limit      DECIMAL(10,2), 
    Validity_days   INT,
    Charge          DECIMAL(10,2)   NOT NULL
);


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


CREATE TABLE Benifit (
    benefit_id          VARCHAR(10)     PRIMARY KEY,
    benefit_name        VARCHAR(100)    NOT NULL,
    benefit_type        VARCHAR(50),
    benefit_provider    VARCHAR(100)
);


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


CREATE TABLE Device (
    IMEI_no             VARCHAR(20)     PRIMARY KEY,
    Device_brand        VARCHAR(50),
    Device_type         VARCHAR(50),
    Device_model        VARCHAR(100),
    Device_status       VARCHAR(20)     DEFAULT 'active',
    Registration_date   TIMESTAMP
);


CREATE TABLE Call_tower (
    Tower_id        INT             PRIMARY KEY,
    capacity        INT,
    covrage_area    VARCHAR(100),
    location        VARCHAR(200),
    Tower_status    VARCHAR(20)     DEFAULT 'active'
);

CREATE TABLE Sim_card (
    Sim_id          VARCHAR(10)     PRIMARY KEY,
    Subscriber_id   VARCHAR(10)     NOT NULL,
    Replace_by      VARCHAR(10)     NULL,          
    Mobile_no       VARCHAR(15)     NOT NULL UNIQUE,
    Sim_status      VARCHAR(20)     DEFAULT 'active',
    Sim_category    VARCHAR(20),                    
    Activation_date TIMESTAMP
);

ALTER TABLE Sim_card
    ADD CONSTRAINT fk_sim_subscriber
        FOREIGN KEY (Subscriber_id) REFERENCES Subscriber(Subscriber_id),
    ADD CONSTRAINT fk_sim_replace
        FOREIGN KEY (Replace_by)    REFERENCES Sim_card(Sim_id);

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


CREATE TABLE SMS (
    SMS_id          VARCHAR(10)     PRIMARY KEY,
    Sim_id          VARCHAR(10)     NOT NULL,
    Date_and_time   TIMESTAMP,
    Charge          DECIMAL(8,2),
    Direcation_SMS  VARCHAR(10),    
    Other_phone_no  VARCHAR(15),

    CONSTRAINT fk_sms_sim
        FOREIGN KEY (Sim_id) REFERENCES Sim_card(Sim_id)
);


CREATE TABLE Data_usage (
    Date        DATE        NOT NULL,
    Sim_id      VARCHAR(10) NOT NULL,
    Data_usage  DECIMAL(12,4),     

    PRIMARY KEY (Date, Sim_id),

    CONSTRAINT fk_datausage_sim
        FOREIGN KEY (Sim_id) REFERENCES Sim_card(Sim_id)
);

CREATE TABLE Call_Record (
    call_id         VARCHAR(12)     PRIMARY KEY,
    Sim_id          VARCHAR(10)     NOT NULL,
    other_phone_no  VARCHAR(15),
    Duration        INT,            
    call_type       VARCHAR(20),    
    call_cost       DECIMAL(8,2),
    Date_and_time   TIMESTAMP,
    Call_direction  VARCHAR(10)

    CONSTRAINT fk_callrec_sim
        FOREIGN KEY (Sim_id) REFERENCES Sim_card(Sim_id)
);

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

CREATE TABLE Tower_Connection (
    Connection_id       INT             PRIMARY KEY,
    Sim_id              VARCHAR(10)     NOT NULL,
    Tower_id            INT             NOT NULL,
    Connect_time        TIMESTAMP,
    Disconnect_time     TIMESTAMP,
    Signal_strength     DECIMAL(6,2),   

    CONSTRAINT fk_tc_sim
        FOREIGN KEY (Sim_id)   REFERENCES Sim_card(Sim_id),
    CONSTRAINT fk_tc_tower
        FOREIGN KEY (Tower_id) REFERENCES Call_tower(Tower_id)
);


CREATE TABLE Payment (
    Transaction_id  VARCHAR(12)     PRIMARY KEY,
    Payment_amount  DECIMAL(12,2)   NOT NULL,
    Payment_method  VARCHAR(50),
    Payment_date    TIMESTAMP,
    Payment_status  VARCHAR(20)     DEFAULT 'pending',
    Payment_for     VARCHAR(20)     CHECK (Payment_for IN ('recharge', 'bill'))
);


CREATE TABLE Recharge (
    Recharge_id     VARCHAR(10)     PRIMARY KEY,
    Sim_plan_id     VARCHAR(10)     NOT NULL,
    Transaction_id  VARCHAR(12)     NOT NULL UNIQUE, 
    GST             DECIMAL(10,2),
    Recharge_amount DECIMAL(10,2),
    Recharge_status VARCHAR(20)     DEFAULT 'success',
    Recharge_Date   TIMESTAMP,

    CONSTRAINT fk_recharge_simplan
        FOREIGN KEY (Sim_plan_id)    REFERENCES Sim_plan(Sim_plan_id),
    CONSTRAINT fk_recharge_payment
        FOREIGN KEY (Transaction_id) REFERENCES Payment(Transaction_id)
);


CREATE TABLE Bill (
    Bill_id         VARCHAR(10)     PRIMARY KEY,
    Transaction_id  VARCHAR(12)     NOT NULL UNIQUE,
    Sim_plan_id     VARCHAR(10)     NOT NULL UNIQUE,
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

