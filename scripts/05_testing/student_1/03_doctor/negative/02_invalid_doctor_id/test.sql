-- [NEGATIVE] Invalid DoctorID format (chk_doc_id)
INSERT INTO Doctor (DoctorID, FirstName, LastName, Gender, Phone, PhoneType, Email, Specialty, DepartmentID)
VALUES ('DOC 01!', 'Bad', 'ID', 'Male', '01099000003', 'Mobile', 'bad.id@hms.org', 'Cardiology', 'DEPT01');
-- Expected: ORA-02290: check constraint (CHK_DOC_ID) violated.
