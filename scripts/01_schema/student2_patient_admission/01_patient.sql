-- Entity: Patient (Student 2)
-- Minimum Data Target: 100 patients
CREATE TABLE Patient (
    PatientID               NUMBER(8)           CONSTRAINT pk_patient PRIMARY KEY,
    FirstName               VARCHAR2(50)        NOT NULL,
    LastName                VARCHAR2(50)        NOT NULL,
    DateOfBirth             DATE                NOT NULL,
    Gender                  VARCHAR2(10)        NOT NULL CONSTRAINT chk_pat_gender CHECK (Gender IN ('Male', 'Female', 'Other')),
    BloodType               VARCHAR2(5)         CONSTRAINT chk_pat_blood CHECK (BloodType IN ('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-')),
    Phone                   VARCHAR2(20)        NOT NULL,
    Address                 VARCHAR2(150)       NOT NULL,
    EmergencyContact        VARCHAR2(20)        NOT NULL,
    Email                   VARCHAR2(100)       CONSTRAINT uq_pat_email UNIQUE
);
