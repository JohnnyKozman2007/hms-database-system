-- Entity: Prescription (Student 4)
-- Minimum Data Target: 300 prescriptions
-- Foreign Keys: PatientID references Patient, DoctorID references Doctor, MedicationID references Medication
CREATE TABLE Prescription (
    PrescriptionID          NUMBER(8)           CONSTRAINT pk_prescription PRIMARY KEY,
    PatientID               NUMBER(8)           NOT NULL,
    DoctorID                NUMBER(5)           NOT NULL,
    MedicationID            NUMBER(5)           NOT NULL,
    Dosage                  VARCHAR2(50)        NOT NULL,
    Frequency               VARCHAR2(50)        NOT NULL,
    Duration                VARCHAR2(50)        NOT NULL,
    PrescriptionDate        DATE                DEFAULT SYSDATE NOT NULL,
    Notes                   VARCHAR2(255),
    CONSTRAINT fk_presc_pat FOREIGN KEY (PatientID) REFERENCES Patient(PatientID),
    CONSTRAINT fk_presc_doc FOREIGN KEY (DoctorID) REFERENCES Doctor(DoctorID),
    CONSTRAINT fk_presc_med FOREIGN KEY (MedicationID) REFERENCES Medication(MedicationID)
);
