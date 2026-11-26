-- [NEGATIVE] Backstop Trigger (trg_procedure_overlap_guard) on rogue raw INSERT overlapping Doctor
BEGIN
    SAVEPOINT sp_test;
    sp_schedule_procedure('PROC_SP1', 'PAT001', 'DOC001', 'Diagnostic Coronary Angiography',
        TO_DATE('2026-12-22 14:00', 'YYYY-MM-DD HH24:MI'), 'OR-1', 90, 15000.00);
    INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, ProcedureDate, Duration, OperatingRoom, ProcedureCost, Outcome)
    VALUES ('PROC_ROG1', 'PAT004', 'DOC001', 'Stent Placement', TO_DATE('2026-12-22 15:00', 'YYYY-MM-DD HH24:MI'), 45, 'OR-2', 12000, 'Pending');
    ROLLBACK TO sp_test;
END;
-- Expected: ORA-20002: Rogue DML Blocked: Doctor already has an active procedure scheduled in this time interval.
