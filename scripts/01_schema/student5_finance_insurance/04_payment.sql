CREATE TABLE Payment (
    PaymentID               VARCHAR2(10)        CONSTRAINT pk_payment PRIMARY KEY,
    InvoiceID               VARCHAR2(10)        NOT NULL,
    PaymentDate             DATE                DEFAULT SYSDATE NOT NULL,
    AmountPaid              NUMBER(10,2)        NOT NULL CONSTRAINT chk_pay_amt CHECK (AmountPaid > 0),
    PaymentMethod           VARCHAR2(30)        NOT NULL CONSTRAINT chk_pay_method CHECK (PaymentMethod IN ('Cash', 'Credit Card', 'Debit Card', 'Bank Transfer', 'Insurance Claim')),
    TransactionReference    VARCHAR2(100)       NOT NULL CONSTRAINT uq_pay_ref UNIQUE,
    PaymentStatus           VARCHAR2(20)        DEFAULT 'Completed' NOT NULL CONSTRAINT chk_pay_status CHECK (PaymentStatus IN ('Completed', 'Pending', 'Failed', 'Refunded')),
    CONSTRAINT fk_pay_invoice FOREIGN KEY (InvoiceID) REFERENCES Invoice(InvoiceID)
);

ALTER TABLE Payment ADD CONSTRAINT chk_pay_id
    CHECK (REGEXP_LIKE(PaymentID, '^[A-Za-z0-9_-]+$'));

ALTER TABLE Payment ADD CONSTRAINT chk_pay_date_lower
    CHECK (PaymentDate >= DATE '2020-01-01');

ALTER TABLE Payment ADD CONSTRAINT chk_pay_ref_fmt
    CHECK (REGEXP_LIKE(TransactionReference, '^[A-Za-z0-9_-]+$') AND LENGTH(TRIM(TransactionReference)) >= 4);
