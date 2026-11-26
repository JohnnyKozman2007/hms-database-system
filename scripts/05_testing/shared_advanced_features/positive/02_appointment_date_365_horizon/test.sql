-- [POSITIVE] Boundary: Appointment.AppointmentDate within 365-day horizon
BEGIN
    SAVEPOINT sp_test;
    UPDATE Appointment SET AppointmentDate = TRUNC(SYSDATE) + 300 + (10/24) WHERE AppointmentID = 'APT001';
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
-- Expected: 1 row updated.
