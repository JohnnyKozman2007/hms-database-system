-- [NEGATIVE] Appointment.AppointmentDate > SYSDATE + 365 (trg_apt_date_horizon)
UPDATE Appointment SET AppointmentDate = SYSDATE + 366 WHERE AppointmentID = 'APT001';
-- Expected: ORA-20001: Appointment.AppointmentDate cannot be more than 365 days in the future.
