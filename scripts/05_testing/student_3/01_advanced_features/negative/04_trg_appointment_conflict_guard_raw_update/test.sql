-- [NEGATIVE] Backstop Trigger (trg_appointment_conflict_guard) on rogue raw UPDATE
BEGIN
    SAVEPOINT sp_test;
    INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason)
    VALUES ('APT_BASE', 'PAT001', 'DOC001', TO_DATE('2026-12-20 10:00', 'YYYY-MM-DD HH24:MI'), 'Scheduled', 'Base slot');
    UPDATE Appointment
    SET DoctorID = 'DOC001', AppointmentDate = TO_DATE('2026-12-20 10:00:30', 'YYYY-MM-DD HH24:MI:SS')
    WHERE AppointmentID = 'APT001';
    ROLLBACK TO sp_test;
END;
-- Expected: ORA-20001: Rogue DML Blocked: Doctor already has an active appointment at this date and time.
