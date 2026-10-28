-- ============================================================================
-- ADVANCED FEATURE: Student 3 (STORED PROCEDURE)
-- Procedure: sp_book_appointment
-- Purpose: Books an appointment after validating doctor availability at specified date/time
-- ============================================================================

CREATE OR REPLACE PROCEDURE sp_book_appointment (
    p_appointment_id IN NUMBER,
    p_patient_id     IN NUMBER,
    p_doctor_id      IN NUMBER,
    p_date           IN DATE,
    p_time           IN VARCHAR2,
    p_reason         IN VARCHAR2,
    p_notes          IN VARCHAR2
) AS
    v_conflict_count NUMBER;
BEGIN
    -- Check if doctor already has a scheduled appointment at the given time
    SELECT COUNT(*)
    INTO v_conflict_count
    FROM Appointment
    WHERE DoctorID = p_doctor_id
      AND AppointmentDate = p_date
      AND AppointmentTime = p_time
      AND Status = 'Scheduled';

    IF v_conflict_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Doctor is already booked for an appointment at this date and time.');
    ELSE
        INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, AppointmentTime, Status, Reason, Notes)
        VALUES (p_appointment_id, p_patient_id, p_doctor_id, p_date, p_time, 'Scheduled', p_reason, p_notes);
        COMMIT;
    END IF;
END;
/
