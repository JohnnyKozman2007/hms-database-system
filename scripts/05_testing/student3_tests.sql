-- ============================================================================
-- TESTING SUITE: Student 3 (Appointment, MedicalRecord, MedicalProcedure)
-- ============================================================================

-- POSITIVE TEST 1: Insert valid Appointment
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, AppointmentTime, Status, Reason, Notes)
VALUES (9999, 1, 1, DATE '2026-06-01', '14:00', 'Scheduled', 'Routine checkup', 'None');
-- Expected: 1 row inserted.

-- NEGATIVE TEST 1: Attempt appointment with invalid Status (CHECK constraint violation)
-- Expected Oracle Error: ORA-02290 (check constraint violated)
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, AppointmentTime, Status, Reason, Notes)
VALUES (9998, 1, 1, DATE '2026-06-01', '15:00', 'UnknownStatus', 'Invalid status test', 'None');

-- NEGATIVE TEST 2: Attempt procedure with negative duration (CHECK constraint violation)
-- Expected Oracle Error: ORA-02290 (check constraint violated)
INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, ProcedureDate, OperatingRoom, Duration, ProcedureCost, Outcome)
VALUES (9999, 1, 1, 'Test Procedure', SYSDATE, 'OR-1', -45, 500.00, 'Successful');

-- NEGATIVE TEST 3: Attempt appointment with nonexistent PatientID (FK constraint violation)
-- Expected Oracle Error: ORA-02291 (parent key not found)
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, AppointmentTime, Status, Reason, Notes)
VALUES (9997, 999999, 1, SYSDATE, '10:00', 'Scheduled', 'Ghost Patient Test', 'None');
ROLLBACK;
