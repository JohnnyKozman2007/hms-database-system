-- [NEGATIVE] Digits in FirstName (chk_doc_fname)
INSERT INTO Doctor (DoctorID, FirstName, LastName, Gender, Phone, PhoneType, Email, Specialty, DepartmentID)
VALUES ('DOC_T2', 'Omar123', 'Ali', 'Male', '01099000004', 'Mobile', 'omar123@hms.org', 'Cardiology', 'DEPT01');
-- Expected: ORA-02290: check constraint (CHK_DOC_FNAME) violated.
