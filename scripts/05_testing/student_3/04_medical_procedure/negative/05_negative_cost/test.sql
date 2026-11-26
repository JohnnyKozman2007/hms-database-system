-- [NEGATIVE] Negative ProcedureCost on UPDATE (chk_proc_cost)
UPDATE MedicalProcedure SET ProcedureCost = -100 WHERE ProcedureID = 'PROC001';
-- Expected: ORA-02290: check constraint (CHK_PROC_COST) violated.
