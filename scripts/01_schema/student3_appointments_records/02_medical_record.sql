-- Entity: MedicalRecord (Student 3)
-- Minimum Data Target: 250 records
-- Foreign Keys: PatientID references Patient, DoctorID references Doctor
CREATE TABLE MedicalRecord (
    RecordID                NUMBER(8)           CONSTRAINT pk_record PRIMARY KEY,
    PatientID               NUMBER(8)           NOT NULL,
    DoctorID                NUMBER(5)           NOT NULL,
    Diagnosis               VARCHAR2(200)       NOT NULL,
    Treatment               VARCHAR2(255)       NOT NULL,
    Notes                   VARCHAR2(255),
    RecordDate              DATE                DEFAULT SYSDATE NOT NULL,
    FollowUpDate            DATE,
    CONSTRAINT fk_rec_pat FOREIGN KEY (PatientID) REFERENCES Patient(PatientID),
    CONSTRAINT fk_rec_doc FOREIGN KEY (DoctorID) REFERENCES Doctor(DoctorID),
    CONSTRAINT chk_rec_dates CHECK (FollowUpDate IS NULL OR FollowUpDate >= RecordDate)
);
