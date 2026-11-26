-- [NEGATIVE] Invalid RecordID (chk_mr_id)
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, RecordDate)
VALUES ('MR*1', 'PAT001', 'DOC001', 'Hypertension', 'Lifestyle changes', DATE '2026-11-11');
-- Expected: ORA-02290: check constraint (CHK_MR_ID) violated.
