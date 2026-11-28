-- [NEGATIVE] Duplicate Doctor Appointment Slot (uq_apt_doc_time)
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes)
SELECT 'APT_DUP1', 'PAT050', DoctorID, AppointmentDate, 'Completed', 'Double booking test', 'Testing unique doctor slot'
FROM Appointment WHERE AppointmentID = 'APT002';
-- Expected: ORA-00001: unique constraint (UQ_APT_DOC_TIME) violated.
