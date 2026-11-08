-- ============================================================================
-- Entity: MedicalRecord (Student 3 - Appointments and Medical Records)
-- Minimum Data Target: 250 records
-- Level 3 Table: Dependent on Patient (PatientID FK) and Doctor (DoctorID FK)
-- ============================================================================

CREATE TABLE MedicalRecord (
    RecordID                NUMBER(8)           CONSTRAINT pk_medical_record PRIMARY KEY,
    PatientID               NUMBER(8)           NOT NULL,
    DoctorID                NUMBER(8)           NOT NULL,
    Diagnosis               VARCHAR2(255)       NOT NULL,
    Treatment               VARCHAR2(500)       NOT NULL,
    Notes                   VARCHAR2(1000),
    RecordDate              DATE                DEFAULT SYSDATE NOT NULL CONSTRAINT chk_mr_rec_date CHECK (RecordDate >= DATE '2020-01-01'),
    FollowUpDate            DATE,
    CONSTRAINT fk_mr_patient FOREIGN KEY (PatientID) REFERENCES Patient(PatientID),
    CONSTRAINT fk_mr_doctor FOREIGN KEY (DoctorID) REFERENCES Doctor(DoctorID),
    CONSTRAINT chk_mr_dates CHECK (FollowUpDate IS NULL OR FollowUpDate >= RecordDate)
);
