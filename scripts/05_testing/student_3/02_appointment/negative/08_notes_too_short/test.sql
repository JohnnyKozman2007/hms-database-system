-- [NEGATIVE] Notes < 5 chars on UPDATE (chk_apt_notes_len)
UPDATE Appointment SET Notes = 'Ok' WHERE AppointmentID = 'APT001';
-- Expected: ORA-02290: check constraint (CHK_APT_NOTES_LEN) violated.
