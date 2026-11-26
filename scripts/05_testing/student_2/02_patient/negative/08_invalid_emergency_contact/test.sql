-- [NEGATIVE - Mohamed] EmergencyContact not a valid 11-digit mobile (chk_pat_emg_num)
INSERT INTO Patient (PatientID, FirstName, LastName, DateOfBirth, Gender, BloodType, Phone, Email, Street, City, PostalCode, EmergencyContact)
VALUES ('PAT994', 'Bad', 'Emg', DATE '1990-01-01', 'Male', 'A+', '01099999994', 'bad.emg994@mail.eg', 'Test Street', 'Cairo', '11511', '0235559999');
-- Expected / Actual (Screenshot): ORA-02290: check constraint (CHK_PAT_EMG_NUM) violated.
