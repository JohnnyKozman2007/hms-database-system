-- ============================================================================
-- Entity: Nurse (Student 1 - Department and Staff Management)
-- Minimum Data Target: 30 nurses
-- Level 2 Table: Dependent on Department (DepartmentID FK)
-- Unary Relationship: SupervisorID references Nurse (NurseID PK)
-- Egyptian National Telecom Plan (Mobile = 11 digits, Landline = 9-10 digits)
-- ============================================================================

CREATE TABLE Nurse (
    NurseID                 NUMBER(8)           CONSTRAINT pk_nurse PRIMARY KEY,
    FirstName               VARCHAR2(50)        NOT NULL,
    LastName                VARCHAR2(50)        NOT NULL,
    FullName                VARCHAR2(101)       GENERATED ALWAYS AS (FirstName || ' ' || LastName) VIRTUAL,
    Gender                  VARCHAR2(10)        NOT NULL CONSTRAINT chk_nurse_gender CHECK (Gender IN ('Male', 'Female')),
    Phone                   VARCHAR2(20)        NOT NULL CONSTRAINT uq_nurse_phone UNIQUE,
    PhoneType               VARCHAR2(10)        DEFAULT 'Mobile' NOT NULL CONSTRAINT chk_nurse_phone_type CHECK (PhoneType IN ('Mobile', 'Landline', 'Phone')),
    Email                   VARCHAR2(100)       NOT NULL 
                                                CONSTRAINT uq_nurse_email UNIQUE
                                                CONSTRAINT chk_nurse_email_fmt CHECK (Email LIKE '%_@__%.__%'),
    Shift                   VARCHAR2(20)        DEFAULT 'Morning' NOT NULL CONSTRAINT chk_nurse_shift CHECK (Shift IN ('Morning', 'Afternoon', 'Night', 'Rotating')),
    HireDate                DATE                DEFAULT SYSDATE NOT NULL,
    YearsOfExperience       NUMBER(2)           DEFAULT 0 NOT NULL CONSTRAINT chk_nurse_exp CHECK (YearsOfExperience BETWEEN 0 AND 60),
    DepartmentID            NUMBER(4)           NOT NULL,
    SupervisorID            NUMBER(8),
    CONSTRAINT fk_nurse_dept FOREIGN KEY (DepartmentID) REFERENCES Department(DepartmentID),
    CONSTRAINT fk_nurse_supervisor FOREIGN KEY (SupervisorID) REFERENCES Nurse(NurseID),
    CONSTRAINT chk_nurse_phone CHECK (
        REGEXP_LIKE(Phone, '^[0-9]+$') AND (
            (PhoneType IN ('Mobile', 'Phone') AND LENGTH(Phone) = 11 AND Phone LIKE '01%') OR
            (PhoneType = 'Landline' AND LENGTH(Phone) IN (9, 10) AND Phone LIKE '0%')
        )
    )
);
