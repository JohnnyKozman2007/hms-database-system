-- [NEGATIVE] Duplicate DoctorID (pk_doctor)
INSERT INTO Doctor (DoctorID, FirstName, LastName, Gender, Phone, PhoneType, Email, Specialty, DepartmentID)
VALUES ('DOC001', 'Dup', 'Doc', 'Male', '01099000002', 'Mobile', 'dup.doc@hms.org', 'Cardiology', 'DEPT01');
-- Expected: ORA-00001: unique constraint (PK_DOCTOR) violated.
