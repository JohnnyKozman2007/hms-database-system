CREATE TABLE Appointment (
    AppointmentID           VARCHAR2(10)        CONSTRAINT pk_appointment PRIMARY KEY,
    PatientID               VARCHAR2(10)        NOT NULL,
    DoctorID                VARCHAR2(10)        NOT NULL,
    AppointmentDate         DATE                DEFAULT SYSDATE NOT NULL CONSTRAINT chk_apt_date CHECK (AppointmentDate >= DATE '2020-01-01'),
    AppointmentTime         VARCHAR2(5)         GENERATED ALWAYS AS (TO_CHAR(AppointmentDate, 'HH24:MI')) VIRTUAL,
    Status                  VARCHAR2(20)        DEFAULT 'Scheduled' NOT NULL CONSTRAINT chk_apt_status CHECK (Status IN ('Scheduled', 'Completed', 'Cancelled', 'No-Show', 'In-Progress', 'Rescheduled')),
    Reason                  VARCHAR2(255)       NOT NULL,
    Notes                   VARCHAR2(500)       CONSTRAINT chk_apt_notes_len CHECK (Notes IS NULL OR LENGTH(TRIM(Notes)) >= 5),
    CONSTRAINT fk_apt_patient FOREIGN KEY (PatientID) REFERENCES Patient(PatientID),
    CONSTRAINT fk_apt_doctor FOREIGN KEY (DoctorID) REFERENCES Doctor(DoctorID),
    CONSTRAINT chk_apt_status_note CHECK (Status NOT IN ('Cancelled', 'Rescheduled', 'No-Show') OR Notes IS NOT NULL),
    CONSTRAINT uq_apt_pat_time UNIQUE (PatientID, AppointmentDate)
);

ALTER TABLE Appointment ADD CONSTRAINT chk_apt_id 
    CHECK (REGEXP_LIKE(AppointmentID, '^[A-Za-z0-9_-]+$'));

ALTER TABLE Appointment ADD CONSTRAINT chk_apt_reason_len 
    CHECK (LENGTH(TRIM(Reason)) >= 5);

ALTER TABLE Appointment ADD CONSTRAINT uq_apt_doc_time 
    UNIQUE (DoctorID, AppointmentDate);
