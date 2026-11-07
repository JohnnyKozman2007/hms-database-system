-- ============================================================================
-- Entity: Department (Student 1 - Department and Staff Management)
-- Minimum Data Target: 8 departments
-- Level 1 Table: Independent entity (No foreign keys)
-- ============================================================================

CREATE TABLE Department (
    DepartmentID            NUMBER(4)           CONSTRAINT pk_department PRIMARY KEY,
    DepartmentName          VARCHAR2(50)        NOT NULL CONSTRAINT uq_dept_name UNIQUE,
    Location                VARCHAR2(50)        NOT NULL,
    Phone                   VARCHAR2(20)        NOT NULL,
    DepartmentDescription   VARCHAR2(255)
);
