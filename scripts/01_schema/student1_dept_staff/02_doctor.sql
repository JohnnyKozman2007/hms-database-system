-- ============================================================================
-- Entity: Doctor (Student 1 - Department and Staff Management)
-- Minimum Data Target: 20 doctors
-- Level 2 Table: Dependent on Department (DepartmentID FK)
-- ============================================================================

CREATE TABLE Doctor (
    DoctorID                NUMBER(8)           CONSTRAINT pk_doctor PRIMARY KEY,
    FirstName               VARCHAR2(50)        NOT NULL,
    LastName                VARCHAR2(50)        NOT NULL,
    Gender                  VARCHAR2(10)        NOT NULL CONSTRAINT chk_doc_gender CHECK (Gender IN ('Male', 'Female')),
    Phone                   VARCHAR2(20)        NOT NULL CONSTRAINT uq_doc_phone UNIQUE,
    Email                   VARCHAR2(100)       NOT NULL CONSTRAINT uq_doc_email UNIQUE,
    Specialty               VARCHAR2(50)        NOT NULL,
    HireDate                DATE                NOT NULL,
    YearsOfExperience       NUMBER(2)           DEFAULT 0 NOT NULL CONSTRAINT chk_doc_exp CHECK (YearsOfExperience >= 0),
    DepartmentID            NUMBER(4)           NOT NULL,
    CONSTRAINT fk_doc_dept FOREIGN KEY (DepartmentID) REFERENCES Department(DepartmentID)
);
