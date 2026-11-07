-- ============================================================================
-- Entity: Nurse (Student 1 - Department and Staff Management)
-- Minimum Data Target: 30 nurses
-- Level 2 Table: Dependent on Department (DepartmentID FK)
-- ============================================================================

CREATE TABLE Nurse (
    NurseID                 NUMBER(8)           CONSTRAINT pk_nurse PRIMARY KEY,
    FirstName               VARCHAR2(50)        NOT NULL,
    LastName                VARCHAR2(50)        NOT NULL,
    Gender                  VARCHAR2(10)        NOT NULL CONSTRAINT chk_nurse_gender CHECK (Gender IN ('Male', 'Female')),
    Phone                   VARCHAR2(20)        NOT NULL CONSTRAINT uq_nurse_phone UNIQUE,
    Email                   VARCHAR2(100)       NOT NULL CONSTRAINT uq_nurse_email UNIQUE,
    Shift                   VARCHAR2(20)        NOT NULL CONSTRAINT chk_nurse_shift CHECK (Shift IN ('Morning', 'Afternoon', 'Night', 'Rotating')),
    YearsOfExperience       NUMBER(2)           DEFAULT 0 NOT NULL CONSTRAINT chk_nurse_exp CHECK (YearsOfExperience >= 0),
    DepartmentID            NUMBER(4)           NOT NULL,
    CONSTRAINT fk_nurse_dept FOREIGN KEY (DepartmentID) REFERENCES Department(DepartmentID)
);
