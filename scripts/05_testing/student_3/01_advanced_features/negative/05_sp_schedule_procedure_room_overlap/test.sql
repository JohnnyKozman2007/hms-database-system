-- [NEGATIVE] sp_schedule_procedure Operating Room Overlap (14:30 - 15:30 in OR-1)
BEGIN
    SAVEPOINT sp_test;
    sp_schedule_procedure('PROC_SP1', 'PAT001', 'DOC001', 'Diagnostic Coronary Angiography',
        TO_DATE('2026-12-22 14:00', 'YYYY-MM-DD HH24:MI'), 'OR-1', 90, 15000.00);
    sp_schedule_procedure('PROC_SP2', 'PAT002', 'DOC002', 'Pacemaker Implantation',
        TO_DATE('2026-12-22 14:30', 'YYYY-MM-DD HH24:MI'), 'OR-1', 60, 25000.00);
    ROLLBACK TO sp_test;
END;
-- Expected: ORA-20003: Operating Room Conflict: Room OR-1 is already occupied.
