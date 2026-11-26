-- [NEGATIVE] Status = 'Cancelled' with NULL Notes on UPDATE (chk_apt_status_note)
UPDATE Appointment SET Status = 'Cancelled', Notes = NULL WHERE AppointmentID = 'APT001';
-- Expected: ORA-02290: check constraint (CHK_APT_STATUS_NOTE) violated.
