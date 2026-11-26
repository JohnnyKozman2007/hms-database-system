-- [POSITIVE - Defaults & NULLs] Omit AppointmentDate (SYSDATE) & Status ('Scheduled'); Notes = NULL
BEGIN
    SAVEPOINT sp_test;
    INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, Reason, Notes)
    VALUES ('APT_DEF_01', 'PAT003', 'DOC003', 'Routine consultation', NULL);
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
-- Expected: 1 row inserted with Status = 'Scheduled' and AppointmentDate = SYSDATE.
