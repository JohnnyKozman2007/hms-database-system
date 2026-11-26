-- [NEGATIVE] Non-existent PatientID (fk_apt_patient)
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason)
VALUES ('APT_T2', 'PAT999', 'DOC001', TO_DATE('2026-12-21 10:00', 'YYYY-MM-DD HH24:MI'), 'Scheduled', 'Checkup');
-- Expected: ORA-02291: integrity constraint (FK_APT_PATIENT) violated.
