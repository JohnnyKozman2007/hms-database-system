CREATE TABLE Medication (
    MedicationID            VARCHAR2(10)        CONSTRAINT pk_medication PRIMARY KEY,
    MedicationName          VARCHAR2(100)       NOT NULL,
    Manufacturer            VARCHAR2(100)       NOT NULL,
    Category                VARCHAR2(50)        NOT NULL CONSTRAINT chk_med_category CHECK (Category IN ('Antibiotic', 'Analgesic', 'Antipyretic', 'Antihypertensive', 'Antidiabetic', 'Anticoagulant', 'Antihistamine', 'Bronchodilator', 'Statin', 'Gastrointestinal', 'Corticosteroid', 'Antidepressant', 'Antiviral', 'Cardiovascular', 'Dermatological', 'Other')),
    DosageForm              VARCHAR2(30)        NOT NULL CONSTRAINT chk_med_dosage_form CHECK (DosageForm IN ('Tablet', 'Capsule', 'Syrup', 'Injection', 'Ointment', 'Cream', 'Inhaler', 'Drops', 'Suspension', 'Patch', 'Suppository')),
    UnitPrice               NUMBER(10, 2)       NOT NULL CONSTRAINT chk_med_unit_price CHECK (UnitPrice > 0 AND UnitPrice <= 50000.00),
    QuantityInStock         NUMBER(6)           DEFAULT 0 NOT NULL CONSTRAINT chk_med_stock CHECK (QuantityInStock >= 0 AND QuantityInStock <= 100000),
    ImportDate              DATE                DEFAULT SYSDATE NOT NULL,
    ExpirationDate          DATE                NOT NULL,
    SupplierID              VARCHAR2(10)        NOT NULL,
    CONSTRAINT fk_med_supplier FOREIGN KEY (SupplierID) REFERENCES Supplier(SupplierID),
    CONSTRAINT chk_med_dates CHECK (ExpirationDate > ImportDate),
    CONSTRAINT uq_med_batch UNIQUE (MedicationName, Manufacturer, DosageForm, ExpirationDate)
);

ALTER TABLE Medication ADD CONSTRAINT chk_med_id 
    CHECK (REGEXP_LIKE(MedicationID, '^[A-Za-z0-9_-]+$'));

ALTER TABLE Medication ADD CONSTRAINT chk_med_name_len 
    CHECK (LENGTH(TRIM(MedicationName)) >= 5);

ALTER TABLE Medication ADD CONSTRAINT chk_med_mfg_len 
    CHECK (LENGTH(TRIM(Manufacturer)) >= 5);
