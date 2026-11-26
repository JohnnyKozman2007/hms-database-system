-- [POSITIVE] Showcase sp_schedule_procedure (Valid Procedure Scheduling)
BEGIN
    SAVEPOINT sp_test;
    sp_schedule_procedure(
        p_procedure_id   => 'PROC_SP1',
        p_patient_id     => 'PAT001',
        p_doctor_id      => 'DOC001',
        p_procedure_name => 'Diagnostic Coronary Angiography',
        p_procedure_date => TO_DATE('2026-12-22 14:00', 'YYYY-MM-DD HH24:MI'),
        p_operating_room => 'OR-1',
        p_duration       => 90,
        p_procedure_cost => 15000.00
    );
    ROLLBACK TO sp_test;
END;
-- Expected: Success message printed; PROC_SP1 scheduled cleanly.
