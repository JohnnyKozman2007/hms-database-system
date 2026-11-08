-- ============================================================================
-- Entity: LaboratoryTest (Student 4 - Pharmacy and Laboratory Management)
-- Minimum Data Target: 200 laboratory tests
-- Level 3 Table: Dependent on Patient (PatientID FK) and Doctor (DoctorID FK)
-- ============================================================================

CREATE TABLE LaboratoryTest (
    TestID                  NUMBER(8)           CONSTRAINT pk_laboratory_test PRIMARY KEY,
    PatientID               NUMBER(8)           NOT NULL,
    DoctorID                NUMBER(8)           NOT NULL,
    TestType                VARCHAR2(100)       NOT NULL,
    RequestedDate           DATE                DEFAULT SYSDATE NOT NULL CONSTRAINT chk_lab_req_date CHECK (RequestedDate >= DATE '2020-01-01'),
    CompletedDate           DATE,
    TestStatus              VARCHAR2(20)        DEFAULT 'Pending' NOT NULL CONSTRAINT chk_lab_status CHECK (TestStatus IN ('Pending', 'In-Progress', 'Completed', 'Cancelled', 'Sample Collected')),
    TestResult              VARCHAR2(500),
    TestCost                NUMBER(10, 2)       NOT NULL CONSTRAINT chk_lab_cost CHECK (TestCost > 0 AND TestCost <= 50000.00),
    CONSTRAINT fk_lab_patient FOREIGN KEY (PatientID) REFERENCES Patient(PatientID),
    CONSTRAINT fk_lab_doctor FOREIGN KEY (DoctorID) REFERENCES Doctor(DoctorID),
    CONSTRAINT chk_lab_dates CHECK (CompletedDate IS NULL OR CompletedDate >= RequestedDate),
    CONSTRAINT chk_lab_status_sync CHECK (
        (TestStatus IN ('Pending', 'In-Progress', 'Sample Collected') AND CompletedDate IS NULL) OR
        (TestStatus = 'Completed' AND CompletedDate IS NOT NULL AND TestResult IS NOT NULL) OR
        (TestStatus = 'Cancelled')
    ),
    CONSTRAINT uq_lab_order UNIQUE (PatientID, DoctorID, TestType, RequestedDate)
);
