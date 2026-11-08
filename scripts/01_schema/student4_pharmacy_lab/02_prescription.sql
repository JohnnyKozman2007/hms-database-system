-- ============================================================================
-- Entity: Prescription (Student 4 - Pharmacy and Laboratory Management)
-- Minimum Data Target: 300 prescriptions
-- Level 4 Table: Dependent on Patient (PatientID FK), Doctor (DoctorID FK), and Medication (MedicationID FK)
-- Virtual Columns: 
--   1. PrescriptionTime: Auto-extracted from PrescriptionDate ('HH24:MI')
--   2. EndDate: Auto-calculated from PrescriptionDate + Duration
-- Business Extensions:
--   - QuantityPrescribed: Units/packages dispensed to patient
--   - DispenseStatus: Lifecycle state ('Pending', 'Dispensed', 'Cancelled')
-- Note on PrescriptionDate: Stores Date + Time (HH24:MI:SS). This allows
-- prescribing the same medication twice on the same day at different times
-- (e.g., morning 08:00 and evening 20:00) while preventing exact duplicate orders.
-- ============================================================================

CREATE TABLE Prescription (
    PrescriptionID          NUMBER(8)           CONSTRAINT pk_prescription PRIMARY KEY,
    PatientID               NUMBER(8)           NOT NULL,
    DoctorID                NUMBER(8)           NOT NULL,
    MedicationID            NUMBER(8)           NOT NULL,
    Dosage                  VARCHAR2(50)        NOT NULL,
    Frequency               VARCHAR2(50)        NOT NULL CONSTRAINT chk_rx_frequency CHECK (Frequency IN ('Once daily', 'Twice daily', 'Three times daily', 'Four times daily', 'Every 4 hours', 'Every 6 hours', 'Every 8 hours', 'Every 12 hours', 'As needed (PRN)', 'At bedtime', 'Weekly', 'Before meals', 'After meals')),
    Duration                NUMBER(3)           NOT NULL CONSTRAINT chk_rx_duration CHECK (Duration > 0 AND Duration <= 365),
    QuantityPrescribed      NUMBER(3)           DEFAULT 1 NOT NULL CONSTRAINT chk_rx_qty CHECK (QuantityPrescribed > 0 AND QuantityPrescribed <= 1000),
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
