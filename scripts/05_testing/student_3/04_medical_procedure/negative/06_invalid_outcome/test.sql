-- [NEGATIVE] Invalid Outcome on UPDATE (chk_proc_outcome)
UPDATE MedicalProcedure SET Outcome = 'Done' WHERE ProcedureID = 'PROC001';
-- Expected: ORA-02290: check constraint (CHK_PROC_OUTCOME) violated.
