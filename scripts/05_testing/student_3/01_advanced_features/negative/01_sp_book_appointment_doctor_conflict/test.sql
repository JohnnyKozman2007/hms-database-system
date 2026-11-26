-- [NEGATIVE] sp_book_appointment Doctor Conflict
BEGIN
    SAVEPOINT sp_test;
    sp_book_appointment('APT_SP1', 'PAT001', 'DOC001', TO_DATE('2026-12-20 10:00', 'YYYY-MM-DD HH24:MI'), 'Initial valid slot');
    sp_book_appointment('APT_SP2', 'PAT002', 'DOC001', TO_DATE('2026-12-20 10:00', 'YYYY-MM-DD HH24:MI'), 'Doctor double booking');
    ROLLBACK TO sp_test;
END;
-- Expected: ORA-20001: Booking Conflict: Doctor DOC001 already has an active appointment.
