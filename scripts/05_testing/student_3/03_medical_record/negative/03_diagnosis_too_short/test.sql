-- [NEGATIVE] Diagnosis < 5 chars on UPDATE (chk_mr_diag_len)
UPDATE MedicalRecord SET Diagnosis = 'Flu' WHERE RecordID = 'MR001';
-- Expected: ORA-02290: check constraint (CHK_MR_DIAG_LEN) violated.
