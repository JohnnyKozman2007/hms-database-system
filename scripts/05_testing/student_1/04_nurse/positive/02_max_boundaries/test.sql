-- [POSITIVE - Max Boundaries] HireDate = TRUNC(SYSDATE), YearsOfExperience = 60, 11-digit Mobile
BEGIN
    SAVEPOINT sp_test;
    INSERT INTO Nurse (NurseID, FirstName, LastName, Gender, Phone, PhoneType, Email, Shift, HireDate, YearsOfExperience, DepartmentID, SupervisorID)
    VALUES ('NUR_MAX_01', 'Noha', 'El-Sayed', 'Male', '01199000001', 'Mobile', 'noha.max@hms.org', 'Rotating', TRUNC(SYSDATE), 60, 'DEPT01', 'NRS001');
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
-- Expected: 1 row inserted.
