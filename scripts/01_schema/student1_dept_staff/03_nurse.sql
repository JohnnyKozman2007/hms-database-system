-- Entity: Nurse (Student 1)
-- Minimum Data Target: 30 nurses
-- Foreign Key: DepartmentID references Department
CREATE TABLE Nurse (
    NurseID                 NUMBER(5)           CONSTRAINT pk_nurse PRIMARY KEY,
    FirstName               VARCHAR2(50)        NOT NULL,
    LastName                VARCHAR2(50)        NOT NULL,
    Gender                  VARCHAR2(10)        NOT NULL CONSTRAINT chk_nurse_gender CHECK (Gender IN ('Male', 'Female', 'Other')),
    Phone                   VARCHAR2(20)        NOT NULL,
    Email                   VARCHAR2(100)       NOT NULL CONSTRAINT uq_nurse_email UNIQUE,
    Shift                   VARCHAR2(20)        NOT NULL CONSTRAINT chk_nurse_shift CHECK (Shift IN ('Day', 'Night', 'Rotational')),
    YearsOfExperience       NUMBER(2)           DEFAULT 0 NOT NULL CONSTRAINT chk_nurse_exp CHECK (YearsOfExperience >= 0),
    DepartmentID            NUMBER(5)           NOT NULL,
    CONSTRAINT fk_nurse_dept FOREIGN KEY (DepartmentID) REFERENCES Department(DepartmentID)
);
