CREATE TABLE MedicalProcedure (
    ProcedureID             VARCHAR2(10)        CONSTRAINT pk_medical_procedure PRIMARY KEY,
    PatientID               VARCHAR2(10)        NOT NULL,
    DoctorID                VARCHAR2(10)        NOT NULL,
    ProcedureName           VARCHAR2(100)       NOT NULL,
    ProcedureDate           DATE                DEFAULT SYSDATE NOT NULL CONSTRAINT chk_proc_date CHECK (ProcedureDate >= DATE '2020-01-01'),
    Duration                NUMBER(4)           NOT NULL CONSTRAINT chk_proc_duration CHECK (Duration > 0 AND Duration <= 1440),
    EndTime                 DATE                GENERATED ALWAYS AS (ProcedureDate + (Duration / 1440)) VIRTUAL,
    OperatingRoom           VARCHAR2(30)        NOT NULL CONSTRAINT chk_proc_room CHECK (OperatingRoom IN ('OR-1', 'OR-2', 'OR-3', 'Cath Lab', 'Endoscopy Suite', 'Minor Surgery 1')),
    ProcedureCost           NUMBER(10, 2)       NOT NULL CONSTRAINT chk_proc_cost CHECK (ProcedureCost > 0 AND ProcedureCost <= 1000000.00),
    Outcome                 VARCHAR2(30)        DEFAULT 'Pending' NOT NULL CONSTRAINT chk_proc_outcome CHECK (Outcome IN ('Pending', 'In-Progress', 'Successful', 'Completed with Complications', 'Unsuccessful', 'Aborted')),
    CONSTRAINT fk_proc_patient FOREIGN KEY (PatientID) REFERENCES Patient(PatientID),
    CONSTRAINT fk_proc_doctor FOREIGN KEY (DoctorID) REFERENCES Doctor(DoctorID),
    CONSTRAINT uq_proc_doc_time UNIQUE (DoctorID, ProcedureDate),
    CONSTRAINT uq_proc_room_time UNIQUE (OperatingRoom, ProcedureDate),
    CONSTRAINT uq_proc_pat_time UNIQUE (PatientID, ProcedureDate)
);

ALTER TABLE MedicalProcedure ADD CONSTRAINT chk_proc_id 
    CHECK (REGEXP_LIKE(ProcedureID, '^[A-Za-z0-9_-]+$'));

ALTER TABLE MedicalProcedure ADD CONSTRAINT chk_proc_name_len 
    CHECK (LENGTH(TRIM(ProcedureName)) >= 5);
