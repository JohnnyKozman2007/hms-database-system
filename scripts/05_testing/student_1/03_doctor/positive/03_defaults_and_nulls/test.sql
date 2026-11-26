-- [POSITIVE - Defaults & NULLs] Omit PhoneType ('Mobile'), HireDate (SYSDATE), YearsOfExperience (0); SupervisorID = NULL
BEGIN
    SAVEPOINT sp_test;
    INSERT INTO Doctor (DoctorID, FirstName, LastName, Gender, Phone, Email, Specialty, DepartmentID, SupervisorID)
    VALUES ('DOC_DEF_01', 'Omar', 'Hassan', 'Male', '01099000009', 'omar.def@hms.org', 'Neurology', 'DEPT01', NULL);
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
-- Expected: 1 row inserted with defaults applied.
