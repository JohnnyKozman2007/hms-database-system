-- [POSITIVE - Valid UPDATE] Cancel appointment with valid Notes
BEGIN
    SAVEPOINT sp_test;
    UPDATE Appointment SET Status = 'Cancelled', Notes = 'Patient requested reschedule' WHERE AppointmentID = 'APT001';
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
-- Expected: 1 row updated.
