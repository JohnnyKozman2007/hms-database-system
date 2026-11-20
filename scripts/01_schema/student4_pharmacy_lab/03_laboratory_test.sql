CREATE TABLE LaboratoryTest (
    TestID                  VARCHAR2(10)        CONSTRAINT pk_laboratory_test PRIMARY KEY,
    PatientID               VARCHAR2(10)        NOT NULL,
    DoctorID                VARCHAR2(10)        NOT NULL,
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
        (TestStatus IN ('Pending', 'In-Progress', 'Sample Collected') AND CompletedDate IS NULL AND TestResult IS NULL) OR
        (TestStatus = 'Completed' AND CompletedDate IS NOT NULL AND TestResult IS NOT NULL) OR
        (TestStatus = 'Cancelled' AND CompletedDate IS NULL)
    ),
    CONSTRAINT uq_lab_order UNIQUE (PatientID, DoctorID, TestType, RequestedDate)
);

ALTER TABLE LaboratoryTest ADD CONSTRAINT chk_lab_id 
    CHECK (REGEXP_LIKE(TestID, '^[A-Za-z0-9_-]+$'));

ALTER TABLE LaboratoryTest ADD CONSTRAINT chk_lab_type_len 
    CHECK (LENGTH(TRIM(TestType)) >= 5);

ALTER TABLE LaboratoryTest ADD CONSTRAINT chk_lab_result_len 
    CHECK (TestResult IS NULL OR LENGTH(TRIM(TestResult)) >= 5);
