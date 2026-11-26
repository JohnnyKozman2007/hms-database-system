-- [NEGATIVE] Invalid AppointmentID (chk_apt_id)
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason)
VALUES ('APT@1', 'PAT002', 'DOC002', TO_DATE('2026-12-21 09:30', 'YYYY-MM-DD HH24:MI'), 'Scheduled', 'Checkup');
-- Expected: ORA-02290: check constraint (CHK_APT_ID) violated.
