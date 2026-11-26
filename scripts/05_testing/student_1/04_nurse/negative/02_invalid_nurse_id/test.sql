-- [NEGATIVE] Invalid NurseID format (chk_nurse_id)
INSERT INTO Nurse (NurseID, FirstName, LastName, Gender, Phone, PhoneType, Email, DepartmentID)
VALUES ('NUR$1', 'Bad', 'ID', 'Female', '01199000003', 'Mobile', 'bad.nurse@hms.org', 'DEPT01');
-- Expected: ORA-02290: check constraint (CHK_NURSE_ID) violated.
