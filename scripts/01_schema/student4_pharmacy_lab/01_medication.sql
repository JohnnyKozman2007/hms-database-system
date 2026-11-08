-- ============================================================================
-- Entity: Medication (Student 4 - Pharmacy and Laboratory Management)
-- Minimum Data Target: 50 medications
-- Level 2 Table: Dependent on Supplier (SupplierID FK)
-- ============================================================================

CREATE TABLE Medication (
    MedicationID            NUMBER(8)           CONSTRAINT pk_medication PRIMARY KEY,
    MedicationName          VARCHAR2(100)       NOT NULL CONSTRAINT uq_med_name UNIQUE,
    Manufacturer            VARCHAR2(100)       NOT NULL,
    Category                VARCHAR2(50)        NOT NULL CONSTRAINT chk_med_category CHECK (Category IN ('Antibiotic', 'Analgesic', 'Antipyretic', 'Antihypertensive', 'Antidiabetic', 'Anticoagulant', 'Antihistamine', 'Bronchodilator', 'Statin', 'Gastrointestinal', 'Corticosteroid', 'Antidepressant', 'Antiviral', 'Cardiovascular', 'Dermatological', 'Other')),
    DosageForm              VARCHAR2(30)        NOT NULL CONSTRAINT chk_med_dosage_form CHECK (DosageForm IN ('Tablet', 'Capsule', 'Syrup', 'Injection', 'Ointment', 'Cream', 'Inhaler', 'Drops', 'Suspension', 'Patch', 'Suppository')),
    UnitPrice               NUMBER(10, 2)       NOT NULL CONSTRAINT chk_med_unit_price CHECK (UnitPrice > 0 AND UnitPrice <= 50000.00),
    QuantityInStock         NUMBER(6)           DEFAULT 0 NOT NULL CONSTRAINT chk_med_stock CHECK (QuantityInStock >= 0 AND QuantityInStock <= 100000),
    ExpirationDate          DATE                NOT NULL CONSTRAINT chk_med_exp_date CHECK (ExpirationDate >= DATE '2020-01-01'),
    SupplierID              NUMBER(5)           NOT NULL,
    CONSTRAINT fk_med_supplier FOREIGN KEY (SupplierID) REFERENCES Supplier(SupplierID)
);
