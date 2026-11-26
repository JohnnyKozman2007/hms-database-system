-- [NEGATIVE] Non-existent DoctorID (fk_apt_doctor)
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason)
VALUES ('APT_T3', 'PAT001', 'DOC999', TO_DATE('2026-12-21 10:30', 'YYYY-MM-DD HH24:MI'), 'Scheduled', 'Checkup');
-- Expected: ORA-02291: integrity constraint (FK_APT_DOCTOR) violated.
