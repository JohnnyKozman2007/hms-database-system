-- Entity: MedicalProcedure (Student 3)
-- Minimum Data Target: 100 procedures
-- Foreign Keys: PatientID references Patient, DoctorID references Doctor
CREATE TABLE MedicalProcedure (
    ProcedureID             NUMBER(8)           CONSTRAINT pk_procedure PRIMARY KEY,
    PatientID               NUMBER(8)           NOT NULL,
    DoctorID                NUMBER(5)           NOT NULL,
    ProcedureName           VARCHAR2(100)       NOT NULL,
    ProcedureDate           DATE                NOT NULL,
    OperatingRoom           VARCHAR2(20)        NOT NULL,
    Duration                NUMBER(4)           NOT NULL CONSTRAINT chk_proc_dur CHECK (Duration > 0),
    ProcedureCost           NUMBER(10,2)        NOT NULL CONSTRAINT chk_proc_cost CHECK (ProcedureCost >= 0),
    Outcome                 VARCHAR2(100)       DEFAULT 'Successful' NOT NULL CONSTRAINT chk_proc_outcome CHECK (Outcome IN ('Successful', 'Complications', 'Under Observation', 'Incomplete')),
    CONSTRAINT fk_proc_pat FOREIGN KEY (PatientID) REFERENCES Patient(PatientID),
    CONSTRAINT fk_proc_doc FOREIGN KEY (DoctorID) REFERENCES Doctor(DoctorID)
);
