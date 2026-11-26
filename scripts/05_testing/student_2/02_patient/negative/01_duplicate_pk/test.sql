-- [NEGATIVE] Duplicate PatientID (pk_patient)
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, Email, Street, City, PostalCode, EmergencyContact)
VALUES ('PAT001', 'Dup', 'Pat', DATE '1990-01-01', 'Male', 'A+', '01099112206', 'dup.pat@mail.eg', 'Test St', 'Cairo', '11511', '01099112207');
-- Expected: ORA-00001: unique constraint (PK_PATIENT) violated.
