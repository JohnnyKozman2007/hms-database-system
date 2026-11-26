-- [POSITIVE - Valid UPDATE] Update DepartmentID & YearsOfExperience
BEGIN
    SAVEPOINT sp_test;
    UPDATE Doctor SET DepartmentID = 'DEPT02', YearsOfExperience = 12 WHERE DoctorID = 'DOC001';
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
-- Expected: 1 row updated.
