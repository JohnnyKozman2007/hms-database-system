-- ============================================================================
-- Entity: Department (Student 1 - Department and Staff Management)
-- Minimum Data Target: 8 departments
-- Level 1 Table: Independent entity (No foreign keys)
-- Egyptian National Telecom Plan (Landline = 9-10 digits, Mobile = 11 digits)
-- ============================================================================

CREATE TABLE Department (
    DepartmentID            NUMBER(4)           CONSTRAINT pk_department PRIMARY KEY,
    DepartmentName          VARCHAR2(50)        NOT NULL CONSTRAINT uq_dept_name UNIQUE,
    Building                VARCHAR2(50)        NOT NULL,
    FloorLevel              VARCHAR2(50)        NOT NULL,
    Location                VARCHAR2(100)       GENERATED ALWAYS AS (Building || ', ' || FloorLevel) VIRTUAL,
    Phone                   VARCHAR2(20)        NOT NULL CONSTRAINT uq_dept_phone UNIQUE,
    PhoneType               VARCHAR2(10)        DEFAULT 'Landline' NOT NULL CONSTRAINT chk_dept_phone_type CHECK (PhoneType IN ('Landline', 'Mobile', 'Phone')),
    DepartmentDescription   VARCHAR2(255),
    CONSTRAINT chk_dept_phone CHECK (
        REGEXP_LIKE(Phone, '^[0-9]+$') AND (
            (PhoneType IN ('Mobile', 'Phone') AND LENGTH(Phone) = 11 AND Phone LIKE '01%') OR
            (PhoneType = 'Landline' AND LENGTH(Phone) IN (9, 10) AND Phone LIKE '0%')
        )
    )
);
