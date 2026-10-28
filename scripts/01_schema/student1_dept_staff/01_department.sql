-- Entity: Department (Student 1)
-- Minimum Data Target: 8 departments
CREATE TABLE Department (
    DepartmentID            NUMBER(5)           CONSTRAINT pk_department PRIMARY KEY,
    DepartmentName          VARCHAR2(50)        NOT NULL CONSTRAINT uq_dept_name UNIQUE,
    Location                VARCHAR2(100)       NOT NULL,
    Phone                   VARCHAR2(20)        NOT NULL,
    DepartmentDescription   VARCHAR2(255)
);
