-- [NEGATIVE] Invalid ProcedureID (chk_proc_id)
INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, ProcedureDate, Duration, OperatingRoom, ProcedureCost)
VALUES ('PROC/1', 'PAT002', 'DOC002', 'Appendectomy', TO_DATE('2026-12-23 12:00', 'YYYY-MM-DD HH24:MI'), 60, 'OR-1', 10000.00);
-- Expected: ORA-02290: check constraint (CHK_PROC_ID) violated.
