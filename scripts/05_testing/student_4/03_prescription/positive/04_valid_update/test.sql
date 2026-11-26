-- [POSITIVE - Valid UPDATE] Update Frequency & Notes
BEGIN
    SAVEPOINT sp_test;
    UPDATE Prescription SET Frequency = 'Every 8 hours', Notes = 'Take with water' WHERE PrescriptionID = 'RX001';
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
-- Expected: 1 row updated.
