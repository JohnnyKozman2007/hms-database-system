CREATE TABLE Insurance (
    InsuranceID             VARCHAR2(10)        CONSTRAINT pk_insurance PRIMARY KEY,
    PatientID               VARCHAR2(10)        NOT NULL,
    InsuranceCompany        VARCHAR2(100)       NOT NULL
                                                CONSTRAINT chk_ins_company CHECK (InsuranceCompany IN ('AXA Egypt', 'Bupa Egypt', 'Allianz Egypt', 'MetLife Egypt', 'Misr Insurance', 'GIG Egypt', 'Delta Insurance', 'Universal Health Insurance')),
    PolicyNumber            VARCHAR2(50)        NOT NULL CONSTRAINT uq_ins_policy UNIQUE,
    CoveragePercentage      NUMBER(5,2)         NOT NULL CONSTRAINT chk_ins_cov CHECK (CoveragePercentage BETWEEN 0 AND 100),
    StartDate               DATE                NOT NULL,
    ExpirationDate          DATE                NOT NULL,
    InsuranceStatus         VARCHAR2(20)        DEFAULT 'Active' NOT NULL CONSTRAINT chk_ins_status CHECK (InsuranceStatus IN ('Active', 'Expired', 'Cancelled', 'Suspended')),
    CONSTRAINT fk_ins_patient FOREIGN KEY (PatientID) REFERENCES Patient(PatientID),
    CONSTRAINT chk_ins_dates CHECK (ExpirationDate > StartDate)
);

ALTER TABLE Insurance ADD CONSTRAINT chk_ins_id
    CHECK (REGEXP_LIKE(InsuranceID, '^[A-Za-z0-9_-]+$'));

ALTER TABLE Insurance ADD CONSTRAINT chk_ins_policy_fmt
    CHECK (REGEXP_LIKE(PolicyNumber, '^[A-Za-z0-9_-]+$') AND LENGTH(TRIM(PolicyNumber)) >= 4);

ALTER TABLE Insurance ADD CONSTRAINT chk_ins_start_date
    CHECK (StartDate >= DATE '2020-01-01');

ALTER TABLE Insurance ADD CONSTRAINT uq_ins_pat_comp_start
    UNIQUE (PatientID, InsuranceCompany, StartDate);

CREATE UNIQUE INDEX uq_ins_one_active_comp
    ON Insurance (
        CASE WHEN InsuranceStatus = 'Active' THEN PatientID END,
        CASE WHEN InsuranceStatus = 'Active' THEN InsuranceCompany END
    );
