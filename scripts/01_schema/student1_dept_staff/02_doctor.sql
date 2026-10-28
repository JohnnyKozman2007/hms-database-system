-- Entity: Doctor (Student 1)
-- Minimum Data Target: 20 doctors
-- Foreign Key: DepartmentID references Department
CREATE TABLE Doctor (
    DoctorID                NUMBER(5)           CONSTRAINT pk_doctor PRIMARY KEY,
    FirstName               VARCHAR2(50)        NOT NULL,
    LastName                VARCHAR2(50)        NOT NULL,
    Gender                  VARCHAR2(10)        NOT NULL CONSTRAINT chk_doc_gender CHECK (Gender IN ('Male', 'Female', 'Other')),
    Phone                   VARCHAR2(20)        NOT NULL,
    Email                   VARCHAR2(100)       NOT NULL CONSTRAINT uq_doc_email UNIQUE,
    Specialty               VARCHAR2(100)       NOT NULL,
    HireDate                DATE                NOT NULL,
    YearsOfExperience       NUMBER(2)           DEFAULT 0 NOT NULL CONSTRAINT chk_doc_exp CHECK (YearsOfExperience >= 0),
    DepartmentID            NUMBER(5)           NOT NULL,
    CONSTRAINT fk_doc_dept FOREIGN KEY (DepartmentID) REFERENCES Department(DepartmentID)
);
