-- [NEGATIVE - Mohamed] FirstName contains digits (chk_pat_fname)
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, Email, Street, City, PostalCode, EmergencyContact)
VALUES ('PAT993', 'Ahmed123', 'Test', DATE '1990-01-01', 'Male', 'A+', '01099999993', 'name.test993@mail.eg', 'Test Street', 'Cairo', '11511', '01299999993');
-- Expected / Actual (Screenshot): ORA-02290: check constraint (CHK_PAT_FNAME) violated.
