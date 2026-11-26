-- [NEGATIVE] Duration = 0 on UPDATE (chk_proc_duration)
UPDATE MedicalProcedure SET Duration = 0 WHERE ProcedureID = 'PROC001';
-- Expected: ORA-02290: check constraint (CHK_PROC_DURATION) violated.
