-- [NEGATIVE - Mohamed] DateOfBirth before 1900-01-01 (chk_pat_dob)
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, Email, Street, City, PostalCode, EmergencyContact)
VALUES ('PAT998', 'Old', 'Person', DATE '1899-12-31', 'Male', 'O+', '01099999998', 'old.person998@mail.eg', 'Test Street', 'Cairo', '11511', '01299999998');
-- Expected / Actual (Screenshot): ORA-02290: check constraint (CHK_PAT_DOB) violated.
