-- [NEGATIVE] MedicalProcedure.ProcedureDate > SYSDATE + 365 (trg_proc_date_horizon)
UPDATE MedicalProcedure SET ProcedureDate = SYSDATE + 400 WHERE ProcedureID = 'PROC001';
-- Expected: ORA-20001: MedicalProcedure.ProcedureDate cannot be more than 365 days in the future.
