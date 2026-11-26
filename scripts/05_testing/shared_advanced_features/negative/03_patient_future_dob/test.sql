-- [NEGATIVE] Future Patient.DateOfBirth (trg_pat_dob_max)
UPDATE Patient SET DateOfBirth = SYSDATE + 10 WHERE PatientID = 'PAT001';
-- Expected: ORA-20001: Patient.DateOfBirth cannot be in the future (exceeds SYSDATE).
