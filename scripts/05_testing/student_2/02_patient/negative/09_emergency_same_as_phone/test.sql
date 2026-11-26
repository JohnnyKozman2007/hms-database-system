-- [NEGATIVE - Mohamed] EmergencyContact same as Phone (chk_pat_emg)
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, Email, Street, City, PostalCode, EmergencyContact)
VALUES ('PAT995', 'Same', 'Contact', DATE '1990-01-01', 'Female', 'B+', '01099999995', 'same.contact995@mail.eg', 'Test Street', 'Cairo', '11511', '01099999995');
-- Expected / Actual (Screenshot): ORA-02290: check constraint (CHK_PAT_EMG) violated.
