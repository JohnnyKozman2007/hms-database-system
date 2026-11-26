-- [NEGATIVE - Mohamed] Invalid BloodType (chk_pat_blood)
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, Email, Street, City, PostalCode, EmergencyContact)
VALUES ('PAT997', 'Bad', 'Blood', DATE '1990-01-01', 'Female', 'C+', '01099999997', 'bad.blood997@mail.eg', 'Test Street', 'Cairo', '11511', '01299999997');
-- Expected / Actual (Screenshot): ORA-02290: check constraint (CHK_PAT_BLOOD) violated.
