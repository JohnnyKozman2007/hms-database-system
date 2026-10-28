-- Entity: Insurance (Student 5)
-- Minimum Data Target: 100 insurance records
-- Foreign Key: PatientID references Patient
CREATE TABLE Insurance (
    InsuranceID             NUMBER(8)           CONSTRAINT pk_insurance PRIMARY KEY,
    PatientID               NUMBER(8)           NOT NULL,
    InsuranceCompany        VARCHAR2(100)       NOT NULL,
    PolicyNumber            VARCHAR2(50)        NOT NULL CONSTRAINT uq_ins_policy UNIQUE,
    CoveragePercentage      NUMBER(5,2)         NOT NULL CONSTRAINT chk_ins_cov CHECK (CoveragePercentage BETWEEN 0 AND 100),
    StartDate               DATE                NOT NULL,
    ExpirationDate          DATE                NOT NULL,
    InsuranceStatus         VARCHAR2(20)        DEFAULT 'Active' NOT NULL CONSTRAINT chk_ins_status CHECK (InsuranceStatus IN ('Active', 'Expired', 'Cancelled', 'Suspended')),
    CONSTRAINT fk_ins_pat FOREIGN KEY (PatientID) REFERENCES Patient(PatientID),
    CONSTRAINT chk_ins_dates CHECK (ExpirationDate >= StartDate)
);
