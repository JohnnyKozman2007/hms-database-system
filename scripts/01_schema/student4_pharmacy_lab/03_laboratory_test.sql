-- Entity: LaboratoryTest (Student 4)
-- Minimum Data Target: 200 tests
-- Foreign Keys: PatientID references Patient, DoctorID references Doctor
CREATE TABLE LaboratoryTest (
    TestID                  NUMBER(8)           CONSTRAINT pk_labtest PRIMARY KEY,
    PatientID               NUMBER(8)           NOT NULL,
    DoctorID                NUMBER(5)           NOT NULL,
    TestType                VARCHAR2(100)       NOT NULL,
    RequestedDate           DATE                NOT NULL,
    CompletedDate           DATE,
    TestStatus              VARCHAR2(20)        DEFAULT 'Pending' NOT NULL CONSTRAINT chk_test_status CHECK (TestStatus IN ('Pending', 'In Progress', 'Completed', 'Cancelled')),
    TestResult              VARCHAR2(255),
    TestCost                NUMBER(10,2)        NOT NULL CONSTRAINT chk_test_cost CHECK (TestCost >= 0),
    CONSTRAINT fk_test_pat FOREIGN KEY (PatientID) REFERENCES Patient(PatientID),
    CONSTRAINT fk_test_doc FOREIGN KEY (DoctorID) REFERENCES Doctor(DoctorID),
    CONSTRAINT chk_test_dates CHECK (CompletedDate IS NULL OR CompletedDate >= RequestedDate)
);
