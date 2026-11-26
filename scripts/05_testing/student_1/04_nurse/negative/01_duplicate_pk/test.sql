-- [NEGATIVE] Duplicate NurseID (pk_nurse)
INSERT INTO Nurse (NurseID, FirstName, LastName, Gender, Phone, PhoneType, Email, DepartmentID)
VALUES ('NRS001', 'Dup', 'Nurse', 'Female', '01199000002', 'Mobile', 'dup.nurse@hms.org', 'DEPT01');
-- Expected: ORA-00001: unique constraint (PK_NURSE) violated.
