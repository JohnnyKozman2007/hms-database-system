-- [POSITIVE - Max Boundaries] TestCost = 50000.00, Completed with CompletedDate & TestResult
BEGIN
    SAVEPOINT sp_test;
    INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost)
    VALUES ('LAB_MAX_01', 'PAT002', 'DOC002', 'Whole Genome Sequencing Panel', TRUNC(SYSDATE), TRUNC(SYSDATE), 'Completed', 'No pathogenic variants detected', 50000.00);
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
-- Expected: 1 row inserted.
