-- ============================================================================
-- Entity: Doctor (Student 1 - Department and Staff Management)
-- Minimum Data Target: 20 doctors
-- Level 2 Table: Dependent on Department (DepartmentID FK)
-- Alphanumeric Primary Key (VARCHAR2) allowing leading zeros and codes (e.g., 'DOC01', '001')
-- Unary Relationship: SupervisorID references Doctor (DoctorID PK)
-- Egyptian National Telecom Plan (Mobile = 11 digits, Landline = 9-10 digits)
-- Constraints defined using ALTER TABLE
-- ============================================================================

CREATE TABLE Doctor (
    DoctorID                VARCHAR2(10),
    FirstName               VARCHAR2(50)        NOT NULL,
    LastName                VARCHAR2(50)        NOT NULL,
    FullName                VARCHAR2(101)       GENERATED ALWAYS AS (FirstName || ' ' || LastName) VIRTUAL,
    Gender                  VARCHAR2(10)        NOT NULL,
    Phone                   VARCHAR2(20)        NOT NULL,
    PhoneType               VARCHAR2(10)        DEFAULT 'Mobile' NOT NULL,
    Email                   VARCHAR2(100)       NOT NULL,
    Specialty               VARCHAR2(50)        NOT NULL,
    HireDate                DATE                DEFAULT SYSDATE NOT NULL,
    YearsOfExperience       NUMBER(2)           DEFAULT 0 NOT NULL,
    DepartmentID            VARCHAR2(10)        NOT NULL,
    SupervisorID            VARCHAR2(10)
);

-- ============================================================================
-- CONSTRAINTS (Student 1 - Doctor)
-- ============================================================================

-- Primary Key
ALTER TABLE Doctor 
    ADD CONSTRAINT pk_doctor PRIMARY KEY (DoctorID);

-- Foreign Keys
ALTER TABLE Doctor 
    ADD CONSTRAINT fk_doc_dept FOREIGN KEY (DepartmentID) REFERENCES Department(DepartmentID);

ALTER TABLE Doctor 
    ADD CONSTRAINT fk_doc_supervisor FOREIGN KEY (SupervisorID) REFERENCES Doctor(DoctorID);

-- Unique Constraints
ALTER TABLE Doctor 
    ADD CONSTRAINT uq_doc_email UNIQUE (Email);

ALTER TABLE Doctor 
    ADD CONSTRAINT uq_doc_phone UNIQUE (Phone);

-- Check Constraints: Alphanumeric ID format
ALTER TABLE Doctor 
    ADD CONSTRAINT chk_doc_id CHECK (REGEXP_LIKE(DoctorID, '^[A-Za-z0-9_-]+$'));

-- Check Constraints: Name Formatting (Alphabetic characters, spaces, hyphens, apostrophes)
ALTER TABLE Doctor 
    ADD CONSTRAINT chk_doc_fname CHECK (REGEXP_LIKE(FirstName, '^[A-Za-z'' -]+$'));

ALTER TABLE Doctor 
    ADD CONSTRAINT chk_doc_lname CHECK (REGEXP_LIKE(LastName, '^[A-Za-z'' -]+$'));

-- Check Constraints: Gender Domain
ALTER TABLE Doctor 
    ADD CONSTRAINT chk_doc_gender CHECK (Gender IN ('Male', 'Female'));

-- Check Constraints: Experience Range
ALTER TABLE Doctor 
    ADD CONSTRAINT chk_doc_exp CHECK (YearsOfExperience BETWEEN 0 AND 60);

-- Check Constraints: Hire Date Historical Boundary
ALTER TABLE Doctor 
    ADD CONSTRAINT chk_doc_hire_date CHECK (HireDate >= DATE '1980-01-01');

-- Check Constraints: Supervisor Cannot Supervise Themselves
ALTER TABLE Doctor 
    ADD CONSTRAINT chk_doc_no_self_sup CHECK (SupervisorID IS NULL OR SupervisorID <> DoctorID);

-- Check Constraints: Email Format
ALTER TABLE Doctor 
    ADD CONSTRAINT chk_doc_email_fmt CHECK (Email LIKE '%_@__%.__%');

-- Check Constraints: Phone Type Domain
ALTER TABLE Doctor 
    ADD CONSTRAINT chk_doc_phone_type CHECK (PhoneType IN ('Mobile', 'Landline'));

-- Check Constraints: Egyptian National Telecom Number Format
ALTER TABLE Doctor 
    ADD CONSTRAINT chk_doc_phone CHECK (
        REGEXP_LIKE(Phone, '^[0-9]+$') AND (
            (PhoneType = 'Mobile' AND LENGTH(Phone) = 11 AND Phone LIKE '01%') OR
            (PhoneType = 'Landline' AND LENGTH(Phone) IN (9, 10) AND Phone LIKE '0%')
        )
    );
