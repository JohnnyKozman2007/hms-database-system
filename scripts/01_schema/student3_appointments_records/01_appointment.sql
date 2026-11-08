-- ============================================================================
-- Entity: Appointment (Student 3 - Appointments and Medical Records)
-- Minimum Data Target: 300 appointments
-- Level 3 Table: Dependent on Patient (PatientID FK) and Doctor (DoctorID FK)
-- Virtual Column: AppointmentTime auto-extracted from AppointmentDate ('HH24:MI')
-- Constraints:
--   - chk_apt_status_note: Explanatory notes mandatory for Cancelled, Rescheduled, or No-Show
--   - uq_apt_pat_time: Guarantees a patient cannot be double-booked at the same start time
-- ============================================================================

CREATE TABLE Appointment (
    AppointmentID           NUMBER(8)           CONSTRAINT pk_appointment PRIMARY KEY,
    PatientID               NUMBER(8)           NOT NULL,
    DoctorID                NUMBER(8)           NOT NULL,
    AppointmentDate         DATE                DEFAULT SYSDATE NOT NULL CONSTRAINT chk_apt_date CHECK (AppointmentDate >= DATE '2020-01-01'),
    AppointmentTime         VARCHAR2(5)         GENERATED ALWAYS AS (TO_CHAR(AppointmentDate, 'HH24:MI')) VIRTUAL,
    Status                  VARCHAR2(20)        DEFAULT 'Scheduled' NOT NULL CONSTRAINT chk_apt_status CHECK (Status IN ('Scheduled', 'Completed', 'Cancelled', 'No-Show', 'In-Progress', 'Rescheduled')),
    Reason                  VARCHAR2(255)       NOT NULL,
    Notes                   VARCHAR2(500),
    CONSTRAINT fk_apt_patient FOREIGN KEY (PatientID) REFERENCES Patient(PatientID),
    CONSTRAINT fk_apt_doctor FOREIGN KEY (DoctorID) REFERENCES Doctor(DoctorID),
    CONSTRAINT chk_apt_status_note CHECK (Status NOT IN ('Cancelled', 'Rescheduled', 'No-Show') OR Notes IS NOT NULL),
    CONSTRAINT uq_apt_pat_time UNIQUE (PatientID, AppointmentDate)
);
