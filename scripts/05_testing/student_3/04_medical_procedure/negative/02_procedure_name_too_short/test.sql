-- [NEGATIVE] ProcedureName < 5 chars on UPDATE (chk_proc_name_len)
UPDATE MedicalProcedure SET ProcedureName = 'Scan' WHERE ProcedureID = 'PROC001';
-- Expected: ORA-02290: check constraint (CHK_PROC_NAME_LEN) violated.
