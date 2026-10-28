-- Entity: Invoice (Student 5)
-- Minimum Data Target: 200 invoices
-- Foreign Key: PatientID references Patient
CREATE TABLE Invoice (
    InvoiceID               NUMBER(8)           CONSTRAINT pk_invoice PRIMARY KEY,
    PatientID               NUMBER(8)           NOT NULL,
    InvoiceDate             DATE                DEFAULT SYSDATE NOT NULL,
    TotalAmount             NUMBER(10,2)        NOT NULL CONSTRAINT chk_inv_total CHECK (TotalAmount >= 0),
    TaxAmount               NUMBER(10,2)        DEFAULT 0.00 NOT NULL CONSTRAINT chk_inv_tax CHECK (TaxAmount >= 0),
    Discount                NUMBER(10,2)        DEFAULT 0.00 NOT NULL CONSTRAINT chk_inv_disc CHECK (Discount >= 0),
    DueDate                 DATE                NOT NULL,
    PaymentStatus           VARCHAR2(20)        DEFAULT 'Unpaid' NOT NULL CONSTRAINT chk_inv_status CHECK (PaymentStatus IN ('Paid', 'Unpaid', 'Partially Paid', 'Overdue')),
    CONSTRAINT fk_inv_pat FOREIGN KEY (PatientID) REFERENCES Patient(PatientID),
    CONSTRAINT chk_inv_dates CHECK (DueDate >= InvoiceDate)
);
