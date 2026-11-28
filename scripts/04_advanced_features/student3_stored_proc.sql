-- ============================================================================
-- ADVANCED DATABASE FEATURE: Student 3
-- Stored Procedure: sp_cancel_appointment
-- Module: Data Modeling for DB (4FTC2063)
-- Subsystem: Appointments and Medical Records
-- ============================================================================

CREATE OR REPLACE PROCEDURE sp_cancel_appointment (
    p_appointment_id IN VARCHAR2,
    p_reason         IN VARCHAR2
) IS
BEGIN
    UPDATE Appointment
    SET Status = 'Cancelled',
        Notes  = p_reason
    WHERE AppointmentID = p_appointment_id;

    IF SQL%ROWCOUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Appointment not found: ' || p_appointment_id);
    END IF;
END sp_cancel_appointment;
/
