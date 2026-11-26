-- [NEGATIVE] Reason < 5 chars on UPDATE (chk_apt_reason_len)
UPDATE Appointment SET Reason = 'Pain' WHERE AppointmentID = 'APT001';
-- Expected: ORA-02290: check constraint (CHK_APT_REASON_LEN) violated.
