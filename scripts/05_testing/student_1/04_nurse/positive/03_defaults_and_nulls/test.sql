-- [POSITIVE - Defaults & NULLs] Omit PhoneType ('Mobile'), Shift ('Morning'), HireDate (SYSDATE), YearsOfExperience (0); SupervisorID = NULL
BEGIN
    SAVEPOINT sp_test;
    INSERT INTO Nurse (NurseID, FirstName, LastName, Gender, Phone, Email, DepartmentID, SupervisorID)
    VALUES ('NUR_DEF_01', 'Salma', 'Adel', 'Female', '01199000009', 'salma.def@hms.org', 'DEPT01', NULL);
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
-- Expected: 1 row inserted with defaults applied.
