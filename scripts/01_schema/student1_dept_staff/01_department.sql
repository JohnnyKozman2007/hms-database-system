-- ============================================================================
-- Entity: Department (Student 1 - Department and Staff Management)
-- Minimum Data Target: 8 departments
-- Level 1 Table: Independent entity (No foreign keys)
-- Alphanumeric Primary Key (VARCHAR2) allowing leading zeros and codes (e.g., 'D01', '001')
-- Building: Code names ('Building A', 'Building B', 'Building C', 'Building D')
-- FloorLevel: Ordinal numbers ('Ground Floor', '1st Floor', '2nd Floor', etc.)
-- Egyptian National Telecom Plan (Landline = 9-10 digits, Mobile = 11 digits)
-- Constraints defined using ALTER TABLE
-- ============================================================================

CREATE TABLE Department (
    DepartmentID            VARCHAR2(10),
    DepartmentName          VARCHAR2(50)        NOT NULL,
    Building                VARCHAR2(50)        NOT NULL,
    FloorLevel              VARCHAR2(20)        NOT NULL,
    Location                VARCHAR2(80)        GENERATED ALWAYS AS (Building || ', ' || FloorLevel) VIRTUAL,
    Phone                   VARCHAR2(20)        NOT NULL,
    PhoneType               VARCHAR2(10)        DEFAULT 'Landline' NOT NULL,
    DepartmentDescription   VARCHAR2(255)
);

-- ============================================================================
-- CONSTRAINTS (Student 1 - Department)
-- ============================================================================

-- Primary Key
ALTER TABLE Department 
    ADD CONSTRAINT pk_department PRIMARY KEY (DepartmentID);

-- Unique Constraints
ALTER TABLE Department 
    ADD CONSTRAINT uq_dept_name UNIQUE (DepartmentName);

ALTER TABLE Department 
    ADD CONSTRAINT uq_dept_phone UNIQUE (Phone);

-- Check Constraints: Alphanumeric ID format
ALTER TABLE Department 
    ADD CONSTRAINT chk_dept_id CHECK (REGEXP_LIKE(DepartmentID, '^[A-Za-z0-9_-]+$'));

-- Check Constraints: Building Code Names
ALTER TABLE Department 
    ADD CONSTRAINT chk_dept_bldg CHECK (
        Building IN ('Building A', 'Building B', 'Building C', 'Building D')
    );

-- Check Constraints: Floor Level Ordinal Numbers
ALTER TABLE Department 
    ADD CONSTRAINT chk_dept_floor CHECK (
        FloorLevel IN ('Ground Floor', '1st Floor', '2nd Floor', '3rd Floor', '4th Floor', '5th Floor')
    );

-- Check Constraints: Phone Type Domain
ALTER TABLE Department 
    ADD CONSTRAINT chk_dept_phone_type CHECK (
        PhoneType IN ('Landline', 'Mobile', 'Phone')
    );

-- Check Constraints: Egyptian National Telecom Number Format
ALTER TABLE Department 
    ADD CONSTRAINT chk_dept_phone CHECK (
        REGEXP_LIKE(Phone, '^[0-9]+$') AND (
            (PhoneType IN ('Mobile', 'Phone') AND LENGTH(Phone) = 11 AND Phone LIKE '01%') OR
            (PhoneType = 'Landline' AND LENGTH(Phone) IN (9, 10) AND Phone LIKE '0%')
        )
    );

