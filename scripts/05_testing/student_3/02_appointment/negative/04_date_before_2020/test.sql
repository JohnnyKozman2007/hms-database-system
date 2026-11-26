-- [NEGATIVE] AppointmentDate before 2020-01-01 on UPDATE (chk_apt_date)
UPDATE Appointment SET AppointmentDate = DATE '2019-12-31' WHERE AppointmentID = 'APT001';
-- Expected: ORA-02290: check constraint (CHK_APT_DATE) violated.
