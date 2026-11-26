-- [NEGATIVE - Mohamed] Invalid Mobile Phone prefix (chk_pat_phone)
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, PhoneType, Email, Street, City, PostalCode, EmergencyContact)
VALUES ('PAT996', 'Bad', 'Phone', DATE '1990-01-01', 'Male', 'A+', '02012345678', 'Mobile', 'bad.phone996@mail.eg', 'Test Street', 'Cairo', '11511', '01299999996');
-- Expected / Actual (Screenshot): ORA-02290: check constraint (CHK_PAT_PHONE) violated.
