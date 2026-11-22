CREATE TABLE Invoice (
    InvoiceID               VARCHAR2(10)        CONSTRAINT pk_invoice PRIMARY KEY,
    PatientID               VARCHAR2(10)        NOT NULL,
    InvoiceDate             DATE                DEFAULT SYSDATE NOT NULL,
    TotalAmount             NUMBER(10,2)        NOT NULL CONSTRAINT chk_inv_total CHECK (TotalAmount > 0),
    TaxAmount               NUMBER(10,2)        GENERATED ALWAYS AS (
                                                    ROUND(TotalAmount * CASE
                                                        WHEN TotalAmount < 1000 THEN 0.05
                                                        WHEN TotalAmount <= 10000 THEN 0.10
                                                        ELSE 0.14
                                                    END, 2)
                                                ) VIRTUAL,
    Discount                NUMBER(10,2)        DEFAULT 0.00 NOT NULL CONSTRAINT chk_inv_disc CHECK (Discount >= 0 AND Discount <= TotalAmount),
    NetAmount               NUMBER(12,2)        GENERATED ALWAYS AS (
                                                    TotalAmount + ROUND(TotalAmount * CASE
                                                        WHEN TotalAmount < 1000 THEN 0.05
                                                        WHEN TotalAmount <= 10000 THEN 0.10
                                                        ELSE 0.14
                                                    END, 2) - Discount
                                                ) VIRTUAL,
    DueDate                 DATE                DEFAULT SYSDATE + 3 NOT NULL,
    PaymentStatus           VARCHAR2(20)        DEFAULT 'Unpaid' NOT NULL CONSTRAINT chk_inv_status CHECK (PaymentStatus IN ('Unpaid', 'Overdue', 'Partially Paid', 'Paid')),
    CONSTRAINT fk_inv_patient FOREIGN KEY (PatientID) REFERENCES Patient(PatientID),
    CONSTRAINT chk_inv_dates CHECK (DueDate >= InvoiceDate AND DueDate <= InvoiceDate + 3)
);

ALTER TABLE Invoice ADD CONSTRAINT chk_inv_id
    CHECK (REGEXP_LIKE(InvoiceID, '^[A-Za-z0-9_-]+$'));

ALTER TABLE Invoice ADD CONSTRAINT chk_inv_date_lower
    CHECK (InvoiceDate >= DATE '2020-01-01');
