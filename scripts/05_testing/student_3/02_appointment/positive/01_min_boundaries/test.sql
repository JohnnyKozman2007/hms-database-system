-- [POSITIVE - Min Boundaries] AppointmentDate = 2020-01-01, 5-char Reason & Notes
BEGIN
    SAVEPOINT sp_test;
    INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes)
    VALUES ('A1', 'PAT001', 'DOC001', DATE '2020-01-01', 'Scheduled', 'Check', 'Valid');
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
-- Expected: 1 row inserted.
