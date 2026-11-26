-- [POSITIVE - Valid UPDATE] Update Outcome & ProcedureCost
BEGIN
    SAVEPOINT sp_test;
    UPDATE MedicalProcedure SET Outcome = 'Successful', ProcedureCost = 20000.00 WHERE ProcedureID = 'PROC001';
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
-- Expected: 1 row updated.
