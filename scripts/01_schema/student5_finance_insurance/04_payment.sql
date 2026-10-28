-- Entity: Payment (Student 5)
-- Minimum Data Target: 250 payments
-- Foreign Key: InvoiceID references Invoice
CREATE TABLE Payment (
    PaymentID               NUMBER(8)           CONSTRAINT pk_payment PRIMARY KEY,
    InvoiceID               NUMBER(8)           NOT NULL,
    PaymentDate             DATE                DEFAULT SYSDATE NOT NULL,
    AmountPaid              NUMBER(10,2)        NOT NULL CONSTRAINT chk_pay_amt CHECK (AmountPaid > 0),
    PaymentMethod           VARCHAR2(30)        NOT NULL CONSTRAINT chk_pay_method CHECK (PaymentMethod IN ('Cash', 'Credit Card', 'Debit Card', 'Bank Transfer', 'Insurance Claim')),
    TransactionReference    VARCHAR2(100)       NOT NULL CONSTRAINT uq_pay_ref UNIQUE,
    PaymentStatus           VARCHAR2(20)        DEFAULT 'Completed' NOT NULL CONSTRAINT chk_pay_status CHECK (PaymentStatus IN ('Completed', 'Pending', 'Failed', 'Refunded')),
    CONSTRAINT fk_pay_inv FOREIGN KEY (InvoiceID) REFERENCES Invoice(InvoiceID)
);
