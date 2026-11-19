-- ============================================================================
-- Entity: Admission (Student 2 - Patient and Admission Management)
-- Minimum Data Target: 150 admissions
-- Level 3 Table: Dependent on Patient (PatientID FK) and Room (RoomID FK)
-- ============================================================================

CREATE TABLE Admission (
    AdmissionID             VARCHAR2(10)        CONSTRAINT pk_admission PRIMARY KEY,
    PatientID               VARCHAR2(10)        NOT NULL,
    RoomID                  VARCHAR2(10)        NOT NULL,
    AdmissionDate           DATE                DEFAULT SYSDATE NOT NULL,
    DischargeDate           DATE,
    AdmissionReason         VARCHAR2(255)       NOT NULL,
    AdmissionStatus         VARCHAR2(20)        DEFAULT 'Admitted' NOT NULL CONSTRAINT chk_adm_status CHECK (AdmissionStatus IN ('Admitted', 'Discharged', 'Transferred')),
    CONSTRAINT fk_adm_patient FOREIGN KEY (PatientID) REFERENCES Patient(PatientID),
    CONSTRAINT fk_adm_room FOREIGN KEY (RoomID) REFERENCES Room(RoomID),
    CONSTRAINT chk_adm_dates CHECK (DischargeDate IS NULL OR DischargeDate >= AdmissionDate),
    CONSTRAINT chk_adm_status_sync CHECK (
        (AdmissionStatus = 'Admitted' AND DischargeDate IS NULL) OR
        (AdmissionStatus IN ('Discharged', 'Transferred') AND DischargeDate IS NOT NULL)
    )
);
