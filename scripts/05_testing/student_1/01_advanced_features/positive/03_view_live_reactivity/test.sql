-- [POSITIVE] Live View Reactivity: Insert Doctor & Nurse into DEPT01 and verify counts increase by 1
DECLARE
    v_doc_before NUMBER;
    v_nrs_before NUMBER;
    v_doc_after  NUMBER;
    v_nrs_after  NUMBER;
BEGIN
    SAVEPOINT sp_test;

    SELECT DoctorCount, NurseCount INTO v_doc_before, v_nrs_before
    FROM vw_department_staff_summary WHERE DepartmentID = 'DEPT01';

    INSERT INTO Doctor (DoctorID, FirstName, LastName, Gender, Phone, PhoneType, Email, Specialty, HireDate, YearsOfExperience, DepartmentID)
    VALUES ('DOC_VW1', 'Youssef', 'Adel', 'Male', '01099887701', 'Mobile', 'youssef.adel@hms.org', 'Cardiology', DATE '2018-01-10', 8, 'DEPT01');

    INSERT INTO Nurse (NurseID, FirstName, LastName, Gender, Phone, PhoneType, Email, Shift, HireDate, YearsOfExperience, DepartmentID)
    VALUES ('NRS_VW1', 'Salma', 'Nader', 'Female', '01199887701', 'Mobile', 'salma.nader@hms.org', 'Morning', DATE '2020-03-15', 6, 'DEPT01');

    SELECT DoctorCount, NurseCount INTO v_doc_after, v_nrs_after
    FROM vw_department_staff_summary WHERE DepartmentID = 'DEPT01';

    DBMS_OUTPUT.PUT_LINE('DEPT01 Doctors: ' || v_doc_before || ' -> ' || v_doc_after || ' | Nurses: ' || v_nrs_before || ' -> ' || v_nrs_after);
    ROLLBACK TO sp_test;
END;
-- Expected: DEPT01 Doctors and Nurses each increase by 1.
