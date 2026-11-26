-- [POSITIVE - Max Boundaries] HireDate = TRUNC(SYSDATE), YearsOfExperience = 60, 11-digit Mobile
BEGIN
    SAVEPOINT sp_test;
    INSERT INTO Doctor (DoctorID, FirstName, LastName, Gender, Phone, PhoneType, Email, Specialty, HireDate, YearsOfExperience, DepartmentID, SupervisorID)
    VALUES ('DOC_MAX_01', 'O''Connor', 'El-Masry', 'Female', '01099000001', 'Mobile', 'doc.max@hms.org', 'Cardiology', TRUNC(SYSDATE), 60, 'DEPT01', 'DOC002');
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
-- Expected: 1 row inserted.
