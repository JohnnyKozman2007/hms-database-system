-- [POSITIVE - Max Boundaries] AppointmentDate = TRUNC(SYSDATE) + 365
BEGIN
    SAVEPOINT sp_test;
    INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes)
    VALUES ('APT_MAX_01', 'PAT002', 'DOC002', TRUNC(SYSDATE) + 365, 'In-Progress', 'Annual cardiology follow-up evaluation', 'Maximum horizon date test');
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
-- Expected: 1 row inserted.
