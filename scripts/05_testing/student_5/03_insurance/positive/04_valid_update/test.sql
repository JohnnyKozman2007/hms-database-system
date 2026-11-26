-- [POSITIVE - Valid UPDATE]
BEGIN
    SAVEPOINT sp_test;
    UPDATE Insurance SET CoveragePercentage = 90.00, InsuranceStatus = 'Suspended' WHERE InsuranceID = 'INS001';
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
-- Expected: 1 row updated.
