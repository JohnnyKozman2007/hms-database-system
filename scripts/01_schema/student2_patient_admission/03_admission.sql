CREATE TABLE Admission (
    AdmissionID             VARCHAR2(10)        CONSTRAINT pk_admission PRIMARY KEY,
    PatientID               VARCHAR2(10)        NOT NULL,
    RoomID                  VARCHAR2(10)        NOT NULL,
    AdmissionDate           DATE                DEFAULT SYSDATE NOT NULL,
    DischargeDate           DATE,
    AdmissionReason         VARCHAR2(255)       NOT NULL,
    AdmissionStatus         VARCHAR2(20)        DEFAULT 'Admitted' NOT NULL CONSTRAINT chk_adm_status CHECK (AdmissionStatus IN ('Admitted', 'Discharged')),
    CONSTRAINT fk_adm_patient FOREIGN KEY (PatientID) REFERENCES Patient(PatientID),
    CONSTRAINT fk_adm_room FOREIGN KEY (RoomID) REFERENCES Room(RoomID),
    CONSTRAINT chk_adm_dates CHECK (DischargeDate IS NULL OR DischargeDate >= AdmissionDate),
    CONSTRAINT chk_adm_status_sync CHECK (
        (AdmissionStatus = 'Admitted' AND DischargeDate IS NULL) OR
        (AdmissionStatus = 'Discharged' AND DischargeDate IS NOT NULL)
    )
);

ALTER TABLE Admission ADD CONSTRAINT chk_adm_id 
    CHECK (REGEXP_LIKE(AdmissionID, '^[A-Za-z0-9_-]+$'));

ALTER TABLE Admission ADD CONSTRAINT chk_adm_date_lower 
    CHECK (AdmissionDate >= DATE '2020-01-01');

ALTER TABLE Admission ADD CONSTRAINT chk_adm_reason_len 
    CHECK (LENGTH(TRIM(AdmissionReason)) >= 5);

ALTER TABLE Admission ADD CONSTRAINT uq_adm_pat_date 
    UNIQUE (PatientID, AdmissionDate);

CREATE UNIQUE INDEX uq_adm_one_active_stay
    ON Admission (CASE WHEN AdmissionStatus = 'Admitted' THEN PatientID END);
