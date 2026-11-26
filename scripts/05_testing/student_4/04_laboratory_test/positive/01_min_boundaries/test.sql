-- [POSITIVE - Min Boundaries] RequestedDate = 2020-01-01, TestCost = 0.01, 5-char TestType
BEGIN
    SAVEPOINT sp_test;
    INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, TestStatus, TestCost)
    VALUES ('L1', 'PAT001', 'DOC001', 'Urine', DATE '2020-01-01', 'Pending', 0.01);
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
-- Expected: 1 row inserted.
