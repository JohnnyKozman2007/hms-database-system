-- ============================================================================
-- SEED DATA: Appointment (Student 3)
-- Target: Minimum 300 appointments
-- ID Range: 1 to 300
-- Foreign Keys: PatientID (1..100), DoctorID (1..20)
-- ============================================================================

INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, AppointmentTime, Status, Reason, Notes)
VALUES (1, 1, 1, DATE '2026-02-10', '09:30', 'Completed', 'Routine cardiac health review', 'Patient reported mild chest fluttering');

INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, AppointmentTime, Status, Reason, Notes)
VALUES (2, 2, 3, DATE '2026-02-12', '11:00', 'Scheduled', 'Migraine and neurological evaluation', 'Requested follow-up MRI');

-- Add remaining appointments (3 to 300) following this exact pattern.
COMMIT;
