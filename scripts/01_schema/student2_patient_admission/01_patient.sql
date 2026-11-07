-- ============================================================================
-- Entity: Patient (Student 2 - Patient and Admission Management)
-- Minimum Data Target: 100 patients
-- Level 1 Table: Independent entity (No foreign keys)
-- Standardized Address Decomposition (matches Supplier architectural standard)
-- Egyptian National Telecom Plan (Mobile = 11 digits, Landline = 9-10 digits)
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
    PhoneType               VARCHAR2(10)        DEFAULT 'Mobile' NOT NULL CONSTRAINT chk_pat_phone_type CHECK (PhoneType IN ('Mobile', 'Landline', 'Phone')),
    Email                   VARCHAR2(100)       NOT NULL 
                                                CONSTRAINT uq_pat_email UNIQUE
                                                CONSTRAINT chk_pat_email_fmt CHECK (Email LIKE '%_@__%.__%'),
    BuildingNumber          VARCHAR2(20),
    Street                  VARCHAR2(100)       NOT NULL,
    City                    VARCHAR2(50)        NOT NULL,
    PostalCode              VARCHAR2(20)        NOT NULL,
    Address                 VARCHAR2(250)       GENERATED ALWAYS AS (BuildingNumber || ' ' || Street || ', ' || City || ' ' || PostalCode) VIRTUAL,
    EmergencyContact        VARCHAR2(20)        NOT NULL,
    CONSTRAINT chk_pat_phone CHECK (
        REGEXP_LIKE(Phone, '^[0-9]+$') AND (
            (PhoneType IN ('Mobile', 'Phone') AND LENGTH(Phone) = 11 AND Phone LIKE '01%') OR
            (PhoneType = 'Landline' AND LENGTH(Phone) IN (9, 10) AND Phone LIKE '0%')
        )
    ),
    CONSTRAINT chk_pat_emg CHECK (EmergencyContact <> Phone),
    CONSTRAINT chk_pat_emg_num CHECK (
        REGEXP_LIKE(EmergencyContact, '^[0-9]+$') AND (
            (LENGTH(EmergencyContact) = 11 AND EmergencyContact LIKE '01%') OR
            (LENGTH(EmergencyContact) IN (9, 10) AND EmergencyContact LIKE '0%')
        )
    )
);
