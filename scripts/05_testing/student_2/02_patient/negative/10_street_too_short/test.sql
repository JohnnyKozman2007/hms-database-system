-- [NEGATIVE - Mohamed] Street shorter than 3 chars (chk_pat_street_len)
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, Email, Street, City, PostalCode, EmergencyContact)
VALUES ('PAT992', 'Short', 'Street', DATE '1990-01-01', 'Female', 'O+', '01099999992', 'short.street992@mail.eg', 'AB', 'Cairo', '11511', '01299999992');
-- Expected / Actual (Screenshot): ORA-02290: check constraint (CHK_PAT_STREET_LEN) violated.
