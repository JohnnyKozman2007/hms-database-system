-- [NEGATIVE] sp_cancel_appointment with non-existent AppointmentID
-- Expected: ORA-20001: Appointment not found: APT999
BEGIN
    sp_cancel_appointment('APT999', 'Patient did not confirm');
END;
/
