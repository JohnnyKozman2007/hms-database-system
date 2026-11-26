-- ============================================================================
-- ORACLE APEX SQL SCRIPT: STUDENT_1
-- Upload in: Oracle APEX -> SQL Workshop -> SQL Scripts -> Upload -> Run
-- All positive DML tests use SAVEPOINT + ROLLBACK (zero permanent changes).
-- ============================================================================

-- [01] student_1\01_advanced_features\positive\01_vw_doctor_dept_workload
-- [POSITIVE] Showcase vw_doctor_dept_workload
SELECT DoctorID, DoctorName, DepartmentName, SupervisorName,
       TotalAppointments, ActiveAppointments, TotalMedicalRecords,
       TotalProcedures, TotalPrescriptions, TotalLabTests
FROM vw_doctor_dept_workload
ORDER BY DoctorID;
-- Expected: 20 rows showing live clinical workload per doctor.

-- [02] student_1\01_advanced_features\positive\02_vw_department_staff_summary
-- [POSITIVE] Showcase vw_department_staff_summary
SELECT DepartmentID, DepartmentName, Location,
       DoctorCount, NurseCount, TotalClinicalStaff,
       AvgDoctorExperience, AvgNurseExperience
FROM vw_department_staff_summary
ORDER BY DepartmentID;
-- Expected: 8 rows summarizing clinical staff counts and experience per department.

-- [03] student_1\01_advanced_features\positive\03_view_live_reactivity
-- Expected: DEPT01 Doctors and Nurses each increase by 1.
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
    VALUES ('DOC_VW1', 'Youssef', 'Adel', 'Male', '01099887701', 'Mobile', 'youssef.vw1@hms.org', 'Cardiology', DATE '2018-01-10', 8, 'DEPT01');

    INSERT INTO Nurse (NurseID, FirstName, LastName, Gender, Phone, PhoneType, Email, Shift, HireDate, YearsOfExperience, DepartmentID)
    VALUES ('NRS_VW1', 'Salma', 'Nader', 'Female', '01199887701', 'Mobile', 'salma.nader@hms.org', 'Morning', DATE '2020-03-15', 6, 'DEPT01');

    SELECT DoctorCount, NurseCount INTO v_doc_after, v_nrs_after
    FROM vw_department_staff_summary WHERE DepartmentID = 'DEPT01';

    DBMS_OUTPUT.PUT_LINE('DEPT01 Doctors: ' || v_doc_before || ' -> ' || v_doc_after || ' | Nurses: ' || v_nrs_before || ' -> ' || v_nrs_after);
    ROLLBACK TO sp_test;
END;
/

-- [04] student_1\02_department\negative\01_duplicate_pk
-- [NEGATIVE] Duplicate DepartmentID (pk_department)
INSERT INTO Department (DepartmentID, DepartmentName, Building, FloorLevel, Phone, PhoneType)
VALUES ('DEPT01', 'Duplicate Dept', 'Building A', '1st Floor', '0227959002', 'Landline');
-- Expected: ORA-00001: unique constraint (PK_DEPARTMENT) violated.

-- [05] student_1\02_department\negative\02_invalid_department_id
-- [NEGATIVE] Invalid DepartmentID characters (chk_dept_id)
INSERT INTO Department (DepartmentID, DepartmentName, Building, FloorLevel, Phone, PhoneType)
VALUES ('DEPT@01', 'Invalid ID Dept', 'Building A', '1st Floor', '0227959003', 'Landline');
-- Expected: ORA-02290: check constraint (CHK_DEPT_ID) violated.

-- [06] student_1\02_department\negative\03_duplicate_department_name
-- [NEGATIVE] Duplicate DepartmentName (uq_dept_name)
INSERT INTO Department (DepartmentID, DepartmentName, Building, FloorLevel, Phone, PhoneType)
VALUES ('DEPT_T2', 'Cardiology', 'Building A', '1st Floor', '0227959004', 'Landline');
-- Expected: ORA-00001: unique constraint (UQ_DEPT_NAME) violated.

-- [07] student_1\02_department\negative\04_null_department_name
-- [NEGATIVE] NULL DepartmentName on UPDATE
UPDATE Department SET DepartmentName = NULL WHERE DepartmentID = 'DEPT01';
-- Expected: ORA-01407: cannot update (DEPARTMENT.DEPARTMENTNAME) to NULL.

-- [08] student_1\02_department\negative\05_invalid_building
-- [NEGATIVE] Invalid Building on UPDATE (chk_dept_bldg)
UPDATE Department SET Building = 'Building X' WHERE DepartmentID = 'DEPT01';
-- Expected: ORA-02290: check constraint (CHK_DEPT_BLDG) violated.

-- [09] student_1\02_department\negative\06_invalid_floor_level
-- [NEGATIVE] Invalid FloorLevel on UPDATE (chk_dept_floor)
UPDATE Department SET FloorLevel = 'Basement' WHERE DepartmentID = 'DEPT01';
-- Expected: ORA-02290: check constraint (CHK_DEPT_FLOOR) violated.

-- [10] student_1\02_department\negative\07_duplicate_phone
-- [NEGATIVE] Duplicate Phone (uq_dept_phone)
INSERT INTO Department (DepartmentID, DepartmentName, Building, FloorLevel, Phone, PhoneType)
VALUES ('DEPT_T5', 'Dup Phone Dept', 'Building A', '1st Floor', '0227951001', 'Landline');
-- Expected: ORA-00001: unique constraint (UQ_DEPT_PHONE) violated.

-- [11] student_1\02_department\negative\08_invalid_phonetype
-- [NEGATIVE] Invalid PhoneType on UPDATE (chk_dept_phone_type / chk_dept_phone)
UPDATE Department SET PhoneType = 'Fax' WHERE DepartmentID = 'DEPT01';
-- Expected: ORA-02290: check constraint (CHK_DEPT_PHONE_TYPE / CHK_DEPT_PHONE) violated.
-- Note: Oracle does not guarantee evaluation order between two overlapping CHECK constraints.

-- [12] student_1\02_department\negative\09_invalid_phone_format
-- [NEGATIVE] Invalid Phone format on UPDATE (chk_dept_phone)
UPDATE Department SET Phone = '12345' WHERE DepartmentID = 'DEPT01';
-- Expected: ORA-02290: check constraint (CHK_DEPT_PHONE) violated.

-- [13] student_1\02_department\positive\01_min_boundaries
-- Expected: 1 row inserted.
-- [POSITIVE - Min Boundaries] Shortest valid ID, name, 9-digit landline
BEGIN
    SAVEPOINT sp_test;
    INSERT INTO Department (DepartmentID, DepartmentName, Building, FloorLevel, Phone, PhoneType, DepartmentDescription)
    VALUES ('D1', 'MinDept', 'Building A', 'Ground Floor', '022795901', 'Landline', 'A');
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
/

-- [14] student_1\02_department\positive\02_max_boundaries
-- Expected: 1 row inserted.
-- [POSITIVE - Max Boundaries] Building D, 5th Floor, 11-digit Mobile
BEGIN
    SAVEPOINT sp_test;
    INSERT INTO Department (DepartmentID, DepartmentName, Building, FloorLevel, Phone, PhoneType, DepartmentDescription)
    VALUES ('DEPT_MAX_1', 'Max Boundary Clinical Department Name', 'Building D', '5th Floor', '01099998888', 'Mobile', 'Maximum boundary department test description.');
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
/

-- [15] student_1\02_department\positive\03_defaults_and_nulls
-- Expected: 1 row inserted with PhoneType = 'Landline'.
-- [POSITIVE - Defaults & NULLs] Omit PhoneType (DEFAULT 'Landline') & DepartmentDescription = NULL
BEGIN
    SAVEPOINT sp_test;
    INSERT INTO Department (DepartmentID, DepartmentName, Building, FloorLevel, Phone, DepartmentDescription)
    VALUES ('DEPT_DEF1', 'Default PhoneType Dept', 'Building B', '2nd Floor', '0227959001', NULL);
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
/

-- [16] student_1\02_department\positive\04_valid_update
-- Expected: 1 row updated.
-- [POSITIVE - Valid UPDATE] Update Building & FloorLevel
BEGIN
    SAVEPOINT sp_test;
    UPDATE Department SET Building = 'Building C', FloorLevel = '3rd Floor' WHERE DepartmentID = 'DEPT01';
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
/

-- [17] student_1\03_doctor\negative\01_duplicate_pk
-- [NEGATIVE] Duplicate DoctorID (pk_doctor)
INSERT INTO Doctor (DoctorID, FirstName, LastName, Gender, Phone, PhoneType, Email, Specialty, DepartmentID)
VALUES ('DOC001', 'Dup', 'Doc', 'Male', '01099000002', 'Mobile', 'dup.doc@hms.org', 'Cardiology', 'DEPT01');
-- Expected: ORA-00001: unique constraint (PK_DOCTOR) violated.

-- [18] student_1\03_doctor\negative\02_invalid_doctor_id
-- [NEGATIVE] Invalid DoctorID format (chk_doc_id)
INSERT INTO Doctor (DoctorID, FirstName, LastName, Gender, Phone, PhoneType, Email, Specialty, DepartmentID)
VALUES ('DOC 01!', 'Bad', 'ID', 'Male', '01099000003', 'Mobile', 'bad.id@hms.org', 'Cardiology', 'DEPT01');
-- Expected: ORA-02290: check constraint (CHK_DOC_ID) violated.

-- [19] student_1\03_doctor\negative\03_invalid_first_name
-- [NEGATIVE] Digits in FirstName (chk_doc_fname)
INSERT INTO Doctor (DoctorID, FirstName, LastName, Gender, Phone, PhoneType, Email, Specialty, DepartmentID)
VALUES ('DOC_T2', 'Omar123', 'Ali', 'Male', '01099000004', 'Mobile', 'omar123@hms.org', 'Cardiology', 'DEPT01');
-- Expected: ORA-02290: check constraint (CHK_DOC_FNAME) violated.

-- [20] student_1\03_doctor\negative\04_invalid_last_name
-- [NEGATIVE] Symbols in LastName on UPDATE (chk_doc_lname)
UPDATE Doctor SET LastName = 'Ali@99' WHERE DoctorID = 'DOC001';
-- Expected: ORA-02290: check constraint (CHK_DOC_LNAME) violated.

-- [21] student_1\03_doctor\negative\05_invalid_gender
-- [NEGATIVE] Invalid Gender on UPDATE (chk_doc_gender)
UPDATE Doctor SET Gender = 'Unknown' WHERE DoctorID = 'DOC001';
-- Expected: ORA-02290: check constraint (CHK_DOC_GENDER) violated.

-- [22] student_1\03_doctor\negative\06_duplicate_phone
-- [NEGATIVE] Duplicate Phone on UPDATE (uq_doc_phone)
UPDATE Doctor SET PhoneType = 'Mobile', Phone = '01012340002' WHERE DoctorID = 'DOC001';
-- Expected: ORA-00001: unique constraint (UQ_DOC_PHONE) violated.

-- [23] student_1\03_doctor\negative\07_invalid_phone_format
-- [NEGATIVE] Invalid Mobile Phone length on UPDATE (chk_doc_phone)
UPDATE Doctor SET PhoneType = 'Mobile', Phone = '010123' WHERE DoctorID = 'DOC001';
-- Expected: ORA-02290: check constraint (CHK_DOC_PHONE) violated.

-- [24] student_1\03_doctor\negative\08_invalid_email_format
-- [NEGATIVE] Invalid Email format on UPDATE (chk_doc_email_fmt)
UPDATE Doctor SET Email = 'invalid_email' WHERE DoctorID = 'DOC001';
-- Expected: ORA-02290: check constraint (CHK_DOC_EMAIL_FMT) violated.

-- [25] student_1\03_doctor\negative\09_duplicate_email
-- [NEGATIVE] Duplicate Email on UPDATE (uq_doc_email)
UPDATE Doctor SET Email = 'ahmed.elsayed@hms.org' WHERE DoctorID = 'DOC001';
-- Expected: ORA-00001: unique constraint (UQ_DOC_EMAIL) violated.

-- [26] student_1\03_doctor\negative\10_null_specialty
-- [NEGATIVE] NULL Specialty on UPDATE
UPDATE Doctor SET Specialty = NULL WHERE DoctorID = 'DOC001';
-- Expected: ORA-01407: cannot update (DOCTOR.SPECIALTY) to NULL.

-- [27] student_1\03_doctor\negative\11_hiredate_before_1980
-- [NEGATIVE] HireDate before 1980-01-01 (chk_doc_hire_date)
UPDATE Doctor SET HireDate = DATE '1970-01-01' WHERE DoctorID = 'DOC001';
-- Expected: ORA-02290: check constraint (CHK_DOC_HIRE_DATE) violated.

-- [28] student_1\03_doctor\negative\12_experience_over_60
-- [NEGATIVE] YearsOfExperience > 60 (chk_doc_exp)
UPDATE Doctor SET YearsOfExperience = 61 WHERE DoctorID = 'DOC001';
-- Expected: ORA-02290: check constraint (CHK_DOC_EXP) violated.

-- [29] student_1\03_doctor\negative\13_invalid_department_fk
-- [NEGATIVE] Non-existent DepartmentID (fk_doc_dept)
UPDATE Doctor SET DepartmentID = 'DEPT999' WHERE DoctorID = 'DOC001';
-- Expected: ORA-02291: integrity constraint (FK_DOC_DEPT) violated.

-- [30] student_1\03_doctor\negative\14_self_supervisor
-- [NEGATIVE] Self-supervision (chk_doc_no_self_sup)
UPDATE Doctor SET SupervisorID = 'DOC001' WHERE DoctorID = 'DOC001';
-- Expected: ORA-02290: check constraint (CHK_DOC_NO_SELF_SUP) violated.

-- [31] student_1\03_doctor\negative\15_invalid_supervisor_fk
-- [NEGATIVE] Non-existent SupervisorID (fk_doc_supervisor)
UPDATE Doctor SET SupervisorID = 'DOC999' WHERE DoctorID = 'DOC001';
-- Expected: ORA-02291: integrity constraint (FK_DOC_SUPERVISOR) violated.

-- [32] student_1\03_doctor\positive\01_min_boundaries
-- Expected: 1 row inserted.
-- [POSITIVE - Min Boundaries] HireDate = 1980-01-01, YearsOfExperience = 0, 9-digit Landline
BEGIN
    SAVEPOINT sp_test;
    INSERT INTO Doctor (DoctorID, FirstName, LastName, Gender, Phone, PhoneType, Email, Specialty, HireDate, YearsOfExperience, DepartmentID, SupervisorID)
    VALUES ('D1', 'A', 'B', 'Male', '022795911', 'Landline', 'a@bc.co', 'General', DATE '1980-01-01', 0, 'DEPT01', 'DOC002');
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
/

-- [33] student_1\03_doctor\positive\02_max_boundaries
-- Expected: 1 row inserted.
-- [POSITIVE - Max Boundaries] HireDate = TRUNC(SYSDATE), YearsOfExperience = 60, 11-digit Mobile
BEGIN
    SAVEPOINT sp_test;
    INSERT INTO Doctor (DoctorID, FirstName, LastName, Gender, Phone, PhoneType, Email, Specialty, HireDate, YearsOfExperience, DepartmentID, SupervisorID)
    VALUES ('DOC_MAX_01', 'O''Connor', 'El-Masry', 'Female', '01099000001', 'Mobile', 'doc.max@hms.org', 'Cardiology', TRUNC(SYSDATE), 60, 'DEPT01', 'DOC002');
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
/

-- [34] student_1\03_doctor\positive\03_defaults_and_nulls
-- Expected: 1 row inserted with defaults applied.
-- [POSITIVE - Defaults & NULLs] Omit PhoneType ('Mobile'), HireDate (SYSDATE), YearsOfExperience (0); SupervisorID = NULL
BEGIN
    SAVEPOINT sp_test;
    INSERT INTO Doctor (DoctorID, FirstName, LastName, Gender, Phone, Email, Specialty, DepartmentID, SupervisorID)
    VALUES ('DOC_DEF_01', 'Omar', 'Hassan', 'Male', '01099000009', 'omar.def@hms.org', 'Neurology', 'DEPT01', NULL);
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
/

-- [35] student_1\03_doctor\positive\04_valid_update
-- Expected: 1 row updated.
-- [POSITIVE - Valid UPDATE] Update DepartmentID & YearsOfExperience
BEGIN
    SAVEPOINT sp_test;
    UPDATE Doctor SET DepartmentID = 'DEPT02', YearsOfExperience = 12 WHERE DoctorID = 'DOC001';
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
/

-- [36] student_1\04_nurse\negative\01_duplicate_pk
-- [NEGATIVE] Duplicate NurseID (pk_nurse)
INSERT INTO Nurse (NurseID, FirstName, LastName, Gender, Phone, PhoneType, Email, DepartmentID)
VALUES ('NRS001', 'Dup', 'Nurse', 'Female', '01199000002', 'Mobile', 'dup.nurse@hms.org', 'DEPT01');
-- Expected: ORA-00001: unique constraint (PK_NURSE) violated.

-- [37] student_1\04_nurse\negative\02_invalid_nurse_id
-- [NEGATIVE] Invalid NurseID format (chk_nurse_id)
INSERT INTO Nurse (NurseID, FirstName, LastName, Gender, Phone, PhoneType, Email, DepartmentID)
VALUES ('NUR$1', 'Bad', 'ID', 'Female', '01199000003', 'Mobile', 'bad.nurse@hms.org', 'DEPT01');
-- Expected: ORA-02290: check constraint (CHK_NURSE_ID) violated.

-- [38] student_1\04_nurse\negative\03_invalid_last_name
-- [NEGATIVE] Digits in LastName (chk_nurse_lname)
UPDATE Nurse SET LastName = 'Samir2' WHERE NurseID = 'NRS001';
-- Expected: ORA-02290: check constraint (CHK_NURSE_LNAME) violated.

-- [39] student_1\04_nurse\negative\04_invalid_gender
-- [NEGATIVE] Invalid Gender (chk_nurse_gender)
UPDATE Nurse SET Gender = 'N/A' WHERE NurseID = 'NRS001';
-- Expected: ORA-02290: check constraint (CHK_NURSE_GENDER) violated.

-- [40] student_1\04_nurse\negative\05_invalid_shift
-- [NEGATIVE] Invalid Shift (chk_nurse_shift)
UPDATE Nurse SET Shift = 'Midnight' WHERE NurseID = 'NRS001';
-- Expected: ORA-02290: check constraint (CHK_NURSE_SHIFT) violated.

-- [41] student_1\04_nurse\negative\06_invalid_phone_format
-- [NEGATIVE] Invalid Mobile Phone prefix (chk_nurse_phone)
UPDATE Nurse SET PhoneType = 'Mobile', Phone = '02279577710' WHERE NurseID = 'NRS001';
-- Expected: ORA-02290: check constraint (CHK_NURSE_PHONE) violated.

-- [42] student_1\04_nurse\negative\07_invalid_email_format
-- [NEGATIVE] Invalid Email format (chk_nurse_email_fmt)
UPDATE Nurse SET Email = 'no-at-sign.org' WHERE NurseID = 'NRS001';
-- Expected: ORA-02290: check constraint (CHK_NURSE_EMAIL_FMT) violated.

-- [43] student_1\04_nurse\negative\08_hiredate_before_1980
-- [NEGATIVE] HireDate before 1980-01-01 (chk_nurse_hire_date)
UPDATE Nurse SET HireDate = DATE '1979-12-31' WHERE NurseID = 'NRS001';
-- Expected: ORA-02290: check constraint (CHK_NURSE_HIRE_DATE) violated.

-- [44] student_1\04_nurse\negative\09_negative_experience
-- [NEGATIVE] Negative YearsOfExperience (chk_nurse_exp)
UPDATE Nurse SET YearsOfExperience = -1 WHERE NurseID = 'NRS001';
-- Expected: ORA-02290: check constraint (CHK_NURSE_EXP) violated.

-- [45] student_1\04_nurse\negative\10_invalid_department_fk
-- [NEGATIVE] Non-existent DepartmentID (fk_nurse_dept)
UPDATE Nurse SET DepartmentID = 'DEPT999' WHERE NurseID = 'NRS001';
-- Expected: ORA-02291: integrity constraint (FK_NURSE_DEPT) violated.

-- [46] student_1\04_nurse\negative\11_self_supervisor
-- [NEGATIVE] Self-supervision (chk_nurse_no_self_sup)
UPDATE Nurse SET SupervisorID = 'NRS001' WHERE NurseID = 'NRS001';
-- Expected: ORA-02290: check constraint (CHK_NURSE_NO_SELF_SUP) violated.

-- [47] student_1\04_nurse\positive\01_min_boundaries
-- Expected: 1 row inserted.
-- [POSITIVE - Min Boundaries] HireDate = 1980-01-01, YearsOfExperience = 0, 9-digit Landline
BEGIN
    SAVEPOINT sp_test;
    INSERT INTO Nurse (NurseID, FirstName, LastName, Gender, Phone, PhoneType, Email, Shift, HireDate, YearsOfExperience, DepartmentID, SupervisorID)
    VALUES ('N1', 'A', 'B', 'Female', '022795922', 'Landline', 'n@bc.co', 'Morning', DATE '1980-01-01', 0, 'DEPT01', 'NRS001');
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
/

-- [48] student_1\04_nurse\positive\02_max_boundaries
-- Expected: 1 row inserted.
-- [POSITIVE - Max Boundaries] HireDate = TRUNC(SYSDATE), YearsOfExperience = 60, 11-digit Mobile
BEGIN
    SAVEPOINT sp_test;
    INSERT INTO Nurse (NurseID, FirstName, LastName, Gender, Phone, PhoneType, Email, Shift, HireDate, YearsOfExperience, DepartmentID, SupervisorID)
    VALUES ('NUR_MAX_01', 'Noha', 'El-Sayed', 'Male', '01199000001', 'Mobile', 'noha.max@hms.org', 'Rotating', TRUNC(SYSDATE), 60, 'DEPT01', 'NRS001');
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
/

-- [49] student_1\04_nurse\positive\03_defaults_and_nulls
-- Expected: 1 row inserted with defaults applied.
-- [POSITIVE - Defaults & NULLs] Omit PhoneType ('Mobile'), Shift ('Morning'), HireDate (SYSDATE), YearsOfExperience (0); SupervisorID = NULL
BEGIN
    SAVEPOINT sp_test;
    INSERT INTO Nurse (NurseID, FirstName, LastName, Gender, Phone, Email, DepartmentID, SupervisorID)
    VALUES ('NUR_DEF_01', 'Salma', 'Adel', 'Female', '01199000009', 'salma.def@hms.org', 'DEPT01', NULL);
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
/

-- [50] student_1\04_nurse\positive\04_valid_update
-- Expected: 1 row updated.
-- [POSITIVE - Valid UPDATE] Update Shift & DepartmentID
BEGIN
    SAVEPOINT sp_test;
    UPDATE Nurse SET Shift = 'Rotating', DepartmentID = 'DEPT03' WHERE NurseID = 'NRS001';
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
/
