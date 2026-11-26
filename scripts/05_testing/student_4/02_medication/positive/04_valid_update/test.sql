-- [POSITIVE - Valid UPDATE] Update UnitPrice & Category
BEGIN
    SAVEPOINT sp_test;
    UPDATE Medication SET UnitPrice = 75.50, Category = 'Antiviral' WHERE MedicationID = 'MED002';
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
-- Expected: 1 row updated.
