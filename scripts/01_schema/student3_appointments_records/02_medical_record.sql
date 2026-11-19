CREATE TABLE MedicalRecord (
    RecordID                VARCHAR2(10)        CONSTRAINT pk_medical_record PRIMARY KEY,
    PatientID               VARCHAR2(10)        NOT NULL,
    DoctorID                VARCHAR2(10)        NOT NULL,
    Diagnosis               VARCHAR2(255)       NOT NULL,
    Treatment               VARCHAR2(500)       NOT NULL,
    Notes                   VARCHAR2(1000),
    RecordDate              DATE                DEFAULT SYSDATE NOT NULL CONSTRAINT chk_mr_rec_date CHECK (RecordDate >= DATE '2020-01-01'),
    FollowUpDate            DATE,
    CONSTRAINT fk_mr_patient FOREIGN KEY (PatientID) REFERENCES Patient(PatientID),
    CONSTRAINT fk_mr_doctor FOREIGN KEY (DoctorID) REFERENCES Doctor(DoctorID),
    CONSTRAINT chk_mr_dates CHECK (FollowUpDate IS NULL OR (FollowUpDate >= RecordDate AND FollowUpDate <= RecordDate + 365)),
    CONSTRAINT uq_mr_encounter UNIQUE (PatientID, DoctorID, RecordDate)
);

ALTER TABLE MedicalRecord ADD CONSTRAINT chk_mr_id 
    CHECK (REGEXP_LIKE(RecordID, '^[A-Za-z0-9_-]+$'));

ALTER TABLE MedicalRecord ADD CONSTRAINT chk_mr_diag_len 
    CHECK (LENGTH(TRIM(Diagnosis)) >= 3);

ALTER TABLE MedicalRecord ADD CONSTRAINT chk_mr_treat_len 
    CHECK (LENGTH(TRIM(Treatment)) >= 3);
