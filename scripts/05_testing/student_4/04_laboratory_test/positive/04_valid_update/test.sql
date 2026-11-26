-- [POSITIVE - Valid UPDATE] Complete a Pending Lab Test with CompletedDate & TestResult
BEGIN
    SAVEPOINT sp_test;
    UPDATE LaboratoryTest SET TestStatus = 'Completed', CompletedDate = TRUNC(SYSDATE), TestResult = 'Normal blood count' WHERE TestID = 'LAB001';
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
-- Expected: 1 row updated.
