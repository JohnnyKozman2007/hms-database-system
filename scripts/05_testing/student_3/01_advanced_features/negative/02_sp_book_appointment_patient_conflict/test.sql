-- [NEGATIVE] sp_book_appointment Patient Conflict
BEGIN
    SAVEPOINT sp_test;
    sp_book_appointment('APT_SP1', 'PAT001', 'DOC001', TO_DATE('2026-12-20 10:00', 'YYYY-MM-DD HH24:MI'), 'Initial valid slot');
    sp_book_appointment('APT_SP3', 'PAT001', 'DOC002', TO_DATE('2026-12-20 10:00', 'YYYY-MM-DD HH24:MI'), 'Patient double booking');
    ROLLBACK TO sp_test;
END;
-- Expected: ORA-20005: Booking Conflict: Patient PAT001 already has an active appointment.
