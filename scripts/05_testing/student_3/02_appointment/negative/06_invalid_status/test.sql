-- [NEGATIVE] Invalid Status on UPDATE (chk_apt_status)
UPDATE Appointment SET Status = 'Delayed' WHERE AppointmentID = 'APT001';
-- Expected: ORA-02290: check constraint (CHK_APT_STATUS) violated.
