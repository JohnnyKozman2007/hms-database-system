-- [POSITIVE] Showcase sp_book_appointment (Valid Booking)
BEGIN
    SAVEPOINT sp_test;
    sp_book_appointment(
        p_appointment_id   => 'APT_SP1',
        p_patient_id       => 'PAT001',
        p_doctor_id        => 'DOC001',
        p_appointment_date => TO_DATE('2026-12-20 10:00', 'YYYY-MM-DD HH24:MI'),
        p_reason           => 'Routine post-op cardiology follow-up',
        p_notes            => 'Patient stable.'
    );
    ROLLBACK TO sp_test;
END;
-- Expected: Success message printed; APT_SP1 booked cleanly.
