-- [POSITIVE - Defaults & NULLs] Omit RequestedDate (SYSDATE), TestStatus ('Pending'); CompletedDate & TestResult = NULL
BEGIN
    SAVEPOINT sp_test;
    INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, CompletedDate, TestResult, TestCost)
    VALUES ('LAB_DEF_01', 'PAT003', 'DOC003', 'Lipid Profile Panel', NULL, NULL, 320.00);
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
-- Expected: 1 row inserted with TestStatus = 'Pending' and RequestedDate = SYSDATE.
