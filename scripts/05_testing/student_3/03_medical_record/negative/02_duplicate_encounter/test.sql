-- [NEGATIVE] Duplicate Encounter (uq_mr_encounter)
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, RecordDate)
SELECT 'MR_T2', PatientID, DoctorID, 'Duplicate Encounter', 'Duplicate Treatment', RecordDate
FROM MedicalRecord WHERE RecordID = 'MR001';
-- Expected: ORA-00001: unique constraint (UQ_MR_ENCOUNTER) violated.
