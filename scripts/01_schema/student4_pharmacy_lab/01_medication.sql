-- Entity: Medication (Student 4)
-- Minimum Data Target: 50 medications
-- Foreign Key: SupplierID references Supplier (Student 5)
CREATE TABLE Medication (
    MedicationID            NUMBER(5)           CONSTRAINT pk_medication PRIMARY KEY,
    MedicationName          VARCHAR2(100)       NOT NULL,
    Manufacturer            VARCHAR2(100)       NOT NULL,
    Category                VARCHAR2(50)        NOT NULL,
    DosageForm              VARCHAR2(50)        NOT NULL CONSTRAINT chk_med_form CHECK (DosageForm IN ('Tablet', 'Capsule', 'Syrup', 'Injection', 'Ointment', 'Inhaler', 'Drops')),
    UnitPrice               NUMBER(10,2)        NOT NULL CONSTRAINT chk_med_price CHECK (UnitPrice > 0),
    QuantityInStock         NUMBER(6)           DEFAULT 0 NOT NULL CONSTRAINT chk_med_stock CHECK (QuantityInStock >= 0),
    ExpirationDate          DATE                NOT NULL,
    SupplierID              NUMBER(5)           NOT NULL,
    CONSTRAINT fk_med_supp FOREIGN KEY (SupplierID) REFERENCES Supplier(SupplierID)
);
