-- ============================================================================
-- Entity: Patient (Student 2 - Patient and Admission Management)
-- Minimum Data Target: 100 patients
-- Level 1 Table: Independent entity (No foreign keys)
-- ============================================================================

CREATE TABLE Patient (
    PatientID               NUMBER(8)           CONSTRAINT pk_patient PRIMARY KEY,
    FirstName               VARCHAR2(50)        NOT NULL,
    LastName                VARCHAR2(50)        NOT NULL,
    FullName                VARCHAR2(101)       GENERATED ALWAYS AS (FirstName || ' ' || LastName) VIRTUAL,
    DateOfBirth             DATE                NOT NULL CONSTRAINT chk_pat_dob CHECK (DateOfBirth >= DATE '1900-01-01'),
    Gender                  VARCHAR2(10)        NOT NULL CONSTRAINT chk_pat_gender CHECK (Gender IN ('Male', 'Female')),
    BloodType               VARCHAR2(5)         NOT NULL CONSTRAINT chk_pat_blood CHECK (BloodType IN ('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-')),
    Phone                   VARCHAR2(20)        NOT NULL CONSTRAINT uq_pat_phone UNIQUE,
    Email                   VARCHAR2(100)       NOT NULL 
                                                CONSTRAINT uq_pat_email UNIQUE
                                                CONSTRAINT chk_pat_email_fmt CHECK (Email LIKE '%_@__%.__%'),
    StreetAddress           VARCHAR2(100)       NOT NULL,
    City                    VARCHAR2(50)        NOT NULL,
    PostalCode              VARCHAR2(20)        NOT NULL,
    Address                 VARCHAR2(200)       GENERATED ALWAYS AS (StreetAddress || ', ' || City || ' ' || PostalCode) VIRTUAL,
    EmergencyContact        VARCHAR2(100)       NOT NULL CONSTRAINT chk_pat_emg CHECK (EmergencyContact <> Phone)
);
