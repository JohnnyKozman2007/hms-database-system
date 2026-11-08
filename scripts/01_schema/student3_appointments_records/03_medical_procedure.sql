-- ============================================================================
-- Entity: MedicalProcedure (Student 3 - Appointments and Medical Records)
-- Minimum Data Target: 100 procedures
-- Level 3 Table: Dependent on Patient (PatientID FK) and Doctor (DoctorID FK)
-- ============================================================================

CREATE TABLE MedicalProcedure (
    ProcedureID             NUMBER(8)           CONSTRAINT pk_medical_procedure PRIMARY KEY,
    PatientID               NUMBER(8)           NOT NULL,
    DoctorID                NUMBER(8)           NOT NULL,
    ProcedureName           VARCHAR2(100)       NOT NULL,
    ProcedureDate           DATE                DEFAULT SYSDATE NOT NULL CONSTRAINT chk_proc_date CHECK (ProcedureDate >= DATE '2020-01-01'),
    OperatingRoom           VARCHAR2(30)        NOT NULL CONSTRAINT chk_proc_room CHECK (OperatingRoom IN ('OR-1', 'OR-2', 'OR-3', 'Cath Lab', 'Endoscopy Suite', 'Minor Surgery 1')),
    Duration                NUMBER(4)           NOT NULL CONSTRAINT chk_proc_duration CHECK (Duration > 0 AND Duration <= 1440),
    ProcedureCost           NUMBER(10, 2)       NOT NULL CONSTRAINT chk_proc_cost CHECK (ProcedureCost > 0 AND ProcedureCost <= 1000000.00),
    Outcome                 VARCHAR2(30)        DEFAULT 'Successful' NOT NULL CONSTRAINT chk_proc_outcome CHECK (Outcome IN ('Successful', 'Completed with Complications', 'Unsuccessful', 'Pending', 'In-Progress', 'Aborted')),
    CONSTRAINT fk_proc_patient FOREIGN KEY (PatientID) REFERENCES Patient(PatientID),
    CONSTRAINT fk_proc_doctor FOREIGN KEY (DoctorID) REFERENCES Doctor(DoctorID)
);
