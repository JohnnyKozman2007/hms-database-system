-- [NEGATIVE] Invalid PatientID format (chk_pat_id)
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, Email, Street, City, PostalCode, EmergencyContact)
VALUES ('PAT@1', 'Bad', 'ID', DATE '1990-01-01', 'Male', 'A+', '01099112208', 'bad.id@mail.eg', 'Test St', 'Cairo', '11511', '01099112209');
-- Expected: ORA-02290: check constraint (CHK_PAT_ID) violated.
