-- [POSITIVE - Min Boundaries] HireDate = 1980-01-01, YearsOfExperience = 0, 9-digit Landline
BEGIN
    SAVEPOINT sp_test;
    INSERT INTO Nurse (NurseID, FirstName, LastName, Gender, Phone, PhoneType, Email, Shift, HireDate, YearsOfExperience, DepartmentID, SupervisorID)
    VALUES ('N1', 'A', 'B', 'Female', '022795922', 'Landline', 'n@bc.co', 'Morning', DATE '1980-01-01', 0, 'DEPT01', 'NRS001');
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
-- Expected: 1 row inserted.
