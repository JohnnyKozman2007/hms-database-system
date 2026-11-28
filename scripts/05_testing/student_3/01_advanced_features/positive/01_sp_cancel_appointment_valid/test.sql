-- [POSITIVE] Showcase sp_cancel_appointment (Valid Cancellation)
-- Expected: Status updated to 'Cancelled' and Notes saved cleanly.
BEGIN
    SAVEPOINT sp_test;
    sp_cancel_appointment('APT001', 'Patient requested cancellation by phone');
    DBMS_OUTPUT.PUT_LINE('Appointment APT001 cancelled successfully.');
    ROLLBACK TO sp_test;
END;
/
