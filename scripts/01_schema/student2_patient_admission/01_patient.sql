-- ============================================================================
-- Entity: Patient (Student 2 - Patient and Admission Management)
-- Minimum Data Target: 100 patients
-- Level 1 Table: Independent entity (No foreign keys)
-- Standardized Address Decomposition (matches Supplier architectural standard)
-- ============================================================================

CREATE TABLE Patient (
    PatientID               NUMBER(8)           CONSTRAINT pk_patient PRIMARY KEY,
    FirstName               VARCHAR2(50)        NOT NULL,
    LastName                VARCHAR2(50)        NOT NULL,
    FullName                VARCHAR2(101)       GENERATED ALWAYS AS (FirstName || ' ' || LastName) VIRTUAL,
    DateOfBirth             DATE                NOT NULL CONSTRAINT chk_pat_dob CHECK (DateOfBirth >= DATE '1900-01-01'),
    Gender                  VARCHAR2(10)        NOT NULL CONSTRAINT chk_pat_gender CHECK (Gender IN ('Male', 'Female')),
    BloodType               VARCHAR2(5)         NOT NULL CONSTRAINT chk_pat_blood CHECK (BloodType IN ('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-')),
    Phone                   VARCHAR2(20)        NOT NULL 
                                                CONSTRAINT uq_pat_phone UNIQUE
                                                CONSTRAINT chk_pat_phone_len CHECK (LENGTH(TRIM(Phone)) >= 7),
    Email                   VARCHAR2(100)       NOT NULL 
                                                CONSTRAINT uq_pat_email UNIQUE
                                                CONSTRAINT chk_pat_email_fmt CHECK (Email LIKE '%_@__%.__%'),
    BuildingNumber          VARCHAR2(20),
    Street                  VARCHAR2(100)       NOT NULL,
    City                    VARCHAR2(50)        NOT NULL,
    PostalCode              VARCHAR2(20)        NOT NULL,
    Address                 VARCHAR2(250)       GENERATED ALWAYS AS (BuildingNumber || ' ' || Street || ', ' || City || ' ' || PostalCode) VIRTUAL,
    EmergencyContact        VARCHAR2(100)       NOT NULL 
                                                CONSTRAINT chk_pat_emg CHECK (EmergencyContact <> Phone)
                                                CONSTRAINT chk_pat_emg_len CHECK (LENGTH(TRIM(EmergencyContact)) >= 7)
);
