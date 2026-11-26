-- [POSITIVE - Min Boundaries] HireDate = 1980-01-01, YearsOfExperience = 0, 9-digit Landline
BEGIN
    SAVEPOINT sp_test;
    INSERT INTO Doctor (DoctorID, FirstName, LastName, Gender, Phone, PhoneType, Email, Specialty, HireDate, YearsOfExperience, DepartmentID, SupervisorID)
    VALUES ('D1', 'A', 'B', 'Male', '022795911', 'Landline', 'a@bc.co', 'General', DATE '1980-01-01', 0, 'DEPT01', 'DOC002');
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
-- Expected: 1 row inserted.
