-- Entity: Admission (Student 2)
-- Minimum Data Target: 150 admissions
-- Foreign Keys: PatientID references Patient, RoomID references Room
CREATE TABLE Admission (
    AdmissionID             NUMBER(8)           CONSTRAINT pk_admission PRIMARY KEY,
    PatientID               NUMBER(8)           NOT NULL,
    RoomID                  NUMBER(5)           NOT NULL,
    AdmissionDate           DATE                NOT NULL,
    DischargeDate           DATE,
    AdmissionReason         VARCHAR2(200)       NOT NULL,
    AdmissionStatus         VARCHAR2(20)        DEFAULT 'Admitted' NOT NULL CONSTRAINT chk_adm_status CHECK (AdmissionStatus IN ('Admitted', 'Discharged', 'Transferred')),
    CONSTRAINT fk_adm_pat FOREIGN KEY (PatientID) REFERENCES Patient(PatientID),
    CONSTRAINT fk_adm_room FOREIGN KEY (RoomID) REFERENCES Room(RoomID),
    CONSTRAINT chk_adm_dates CHECK (DischargeDate IS NULL OR DischargeDate >= AdmissionDate)
);
