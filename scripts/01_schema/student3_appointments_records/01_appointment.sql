-- Entity: Appointment (Student 3)
-- Minimum Data Target: 300 appointments
-- Foreign Keys: PatientID references Patient, DoctorID references Doctor
CREATE TABLE Appointment (
    AppointmentID           NUMBER(8)           CONSTRAINT pk_appointment PRIMARY KEY,
    PatientID               NUMBER(8)           NOT NULL,
    DoctorID                NUMBER(5)           NOT NULL,
    AppointmentDate         DATE                NOT NULL,
    AppointmentTime         VARCHAR2(10)        NOT NULL,
    Status                  VARCHAR2(20)        DEFAULT 'Scheduled' NOT NULL CONSTRAINT chk_apt_status CHECK (Status IN ('Scheduled', 'Completed', 'Cancelled', 'No-Show')),
    Reason                  VARCHAR2(200)       NOT NULL,
    Notes                   VARCHAR2(255),
    CONSTRAINT fk_apt_pat FOREIGN KEY (PatientID) REFERENCES Patient(PatientID),
    CONSTRAINT fk_apt_doc FOREIGN KEY (DoctorID) REFERENCES Doctor(DoctorID)
);
