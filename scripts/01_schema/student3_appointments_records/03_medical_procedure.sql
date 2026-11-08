-- ============================================================================
-- Entity: MedicalProcedure (Student 3 - Appointments and Medical Records)
-- Minimum Data Target: 100 procedures
-- Level 3 Table: Dependent on Patient (PatientID FK) and Doctor (DoctorID FK)
-- Virtual Column: EndTime auto-calculated from ProcedureDate + Duration
-- Constraints:
--   - chk_proc_outcome: Restricts lifecycle states, defaulting to 'Pending' upon booking
--   - uq_proc_doc_time: Guarantees a doctor cannot start two procedures simultaneously
--   - uq_proc_room_time: Guarantees an operating room cannot host two procedures simultaneously
--   - uq_proc_pat_time: Guarantees a patient cannot be scheduled for two procedures simultaneously
-- ============================================================================

CREATE TABLE MedicalProcedure (
    ProcedureID             NUMBER(8)           CONSTRAINT pk_medical_procedure PRIMARY KEY,
    PatientID               NUMBER(8)           NOT NULL,
    DoctorID                NUMBER(8)           NOT NULL,
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
