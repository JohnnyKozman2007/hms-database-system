CREATE TABLE Prescription (
    PrescriptionID          VARCHAR2(10)        CONSTRAINT pk_prescription PRIMARY KEY,
    PatientID               VARCHAR2(10)        NOT NULL,
    DoctorID                VARCHAR2(10)        NOT NULL,
    MedicationID            VARCHAR2(10)        NOT NULL,
    Dosage                  VARCHAR2(50)        NOT NULL,
    Frequency               VARCHAR2(50)        NOT NULL CONSTRAINT chk_rx_frequency CHECK (Frequency IN ('Once daily', 'Twice daily', 'Three times daily', 'Four times daily', 'Every 4 hours', 'Every 6 hours', 'Every 8 hours', 'Every 12 hours', 'As needed (PRN)', 'At bedtime', 'Weekly', 'Before meals', 'After meals')),
    Duration                NUMBER(3)           NOT NULL CONSTRAINT chk_rx_duration CHECK (Duration > 0 AND Duration <= 365),
    QuantityPrescribed      NUMBER(4)           DEFAULT 1 NOT NULL CONSTRAINT chk_rx_qty CHECK (QuantityPrescribed > 0 AND QuantityPrescribed <= 1000),
    DispenseStatus          VARCHAR2(20)        DEFAULT 'Pending' NOT NULL CONSTRAINT chk_rx_dispense CHECK (DispenseStatus IN ('Pending', 'Dispensed', 'Cancelled')),
    PrescriptionDate        DATE                DEFAULT SYSDATE NOT NULL CONSTRAINT chk_rx_date CHECK (PrescriptionDate >= DATE '2020-01-01'),
    PrescriptionTime        VARCHAR2(5)         GENERATED ALWAYS AS (TO_CHAR(PrescriptionDate, 'HH24:MI')) VIRTUAL,
    EndDate                 DATE                GENERATED ALWAYS AS (PrescriptionDate + Duration) VIRTUAL,
    Notes                   VARCHAR2(500),
    CONSTRAINT fk_rx_patient FOREIGN KEY (PatientID) REFERENCES Patient(PatientID),
    CONSTRAINT fk_rx_doctor FOREIGN KEY (DoctorID) REFERENCES Doctor(DoctorID),
    CONSTRAINT fk_rx_medication FOREIGN KEY (MedicationID) REFERENCES Medication(MedicationID),
    CONSTRAINT uq_rx_order UNIQUE (PatientID, DoctorID, MedicationID, PrescriptionDate)
);

ALTER TABLE Prescription ADD CONSTRAINT chk_rx_id 
    CHECK (REGEXP_LIKE(PrescriptionID, '^[A-Za-z0-9_-]+$'));

ALTER TABLE Prescription ADD CONSTRAINT chk_rx_notes_len 
    CHECK (Notes IS NULL OR LENGTH(TRIM(Notes)) >= 5);
