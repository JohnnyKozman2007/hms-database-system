-- ============================================================================
-- ADVANCED DATABASE FEATURE: Student 3
-- Stored Procedures: Conflict-Free Scheduling Engine
-- Module: Data Modeling for DB (4FTC2063)
-- Subsystem: Appointments and Medical Records
-- ============================================================================
-- This script defines transactional stored procedures to eliminate scheduling
-- conflicts for both outpatient consultations (Appointment) and surgical
-- operations (MedicalProcedure).
--
-- Procedures included:
-- 1. sp_book_appointment: Books an appointment verifying doctor availability.
-- 2. sp_schedule_procedure: Schedules a surgical procedure verifying both
--    Doctor schedule availability and Operating Room interval availability.
-- ============================================================================

SET SERVEROUTPUT ON;

-- ----------------------------------------------------------------------------
-- 1. PROCEDURE: sp_book_appointment
-- Description: Books an appointment, ensuring the doctor does not already have
--              an active scheduled appointment at the exact requested time.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE sp_book_appointment (
    p_appointment_id   IN NUMBER,
    p_patient_id       IN NUMBER,
    p_doctor_id        IN NUMBER,
    p_appointment_date IN DATE,
    p_reason           IN VARCHAR2,
    p_notes            IN VARCHAR2 DEFAULT NULL
) IS
    v_patient_exists NUMBER := 0;
    v_doctor_exists  NUMBER := 0;
    v_conflict_count NUMBER := 0;
    v_time_str       VARCHAR2(5);
BEGIN
    -- 1. Validate Patient existence
    SELECT COUNT(*) INTO v_patient_exists
    FROM Patient
    WHERE PatientID = p_patient_id;

    IF v_patient_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20010, 'Error: Patient ID ' || p_patient_id || ' does not exist in the database.');
    END IF;

    -- 2. Validate Doctor existence
    SELECT COUNT(*) INTO v_doctor_exists
    FROM Doctor
    WHERE DoctorID = p_doctor_id;

    IF v_doctor_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20011, 'Error: Doctor ID ' || p_doctor_id || ' does not exist in the database.');
    END IF;

    -- 3. Extract time string for logging/checking
    v_time_str := TO_CHAR(p_appointment_date, 'HH24:MI');

    -- 4. Check for active appointment conflict for the doctor
    SELECT COUNT(*)
    INTO v_conflict_count
    FROM Appointment
    WHERE DoctorID = p_doctor_id
      AND TRUNC(AppointmentDate) = TRUNC(p_appointment_date)
      AND AppointmentTime = v_time_str
      AND Status IN ('Scheduled', 'In-Progress');

    IF v_conflict_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Booking Conflict: Doctor ' || p_doctor_id || 
            ' already has an active appointment at ' || TO_CHAR(p_appointment_date, 'YYYY-MM-DD HH24:MI') || '.');
    END IF;

    -- 5. Insert clean appointment tuple
    INSERT INTO Appointment (
        AppointmentID,
        PatientID,
        DoctorID,
        AppointmentDate,
        Status,
        Reason,
        Notes
    ) VALUES (
        p_appointment_id,
        p_patient_id,
        p_doctor_id,
        p_appointment_date,
        'Scheduled',
        p_reason,
        p_notes
    );

    DBMS_OUTPUT.PUT_LINE('Success: Appointment #' || p_appointment_id || 
                         ' successfully booked for Patient ' || p_patient_id || 
                         ' with Doctor ' || p_doctor_id || ' at ' || TO_CHAR(p_appointment_date, 'YYYY-MM-DD HH24:MI') || '.');
END sp_book_appointment;
/

-- ----------------------------------------------------------------------------
-- 2. PROCEDURE: sp_schedule_procedure
-- Description: Schedules a medical/surgical procedure, verifying that neither
--              the Doctor nor the Operating Room has an overlapping time window.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE sp_schedule_procedure (
    p_procedure_id     IN NUMBER,
    p_patient_id       IN NUMBER,
    p_doctor_id        IN NUMBER,
    p_procedure_name   IN VARCHAR2,
    p_procedure_date   IN DATE,
    p_operating_room   IN VARCHAR2,
    p_duration         IN NUMBER,
    p_procedure_cost   IN NUMBER
) IS
    v_patient_exists  NUMBER := 0;
    v_doctor_exists   NUMBER := 0;
    v_doc_conflicts   NUMBER := 0;
    v_room_conflicts  NUMBER := 0;
    v_new_end_time    DATE;
BEGIN
    -- 1. Validate Duration
    IF p_duration <= 0 OR p_duration > 1440 THEN
        RAISE_APPLICATION_ERROR(-20020, 'Error: Duration must be between 1 and 1440 minutes.');
    END IF;

    -- 2. Validate Cost
    IF p_procedure_cost <= 0 THEN
        RAISE_APPLICATION_ERROR(-20021, 'Error: Procedure cost must be strictly positive.');
    END IF;

    -- 3. Validate Patient existence
    SELECT COUNT(*) INTO v_patient_exists
    FROM Patient
    WHERE PatientID = p_patient_id;

    IF v_patient_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20010, 'Error: Patient ID ' || p_patient_id || ' does not exist in the database.');
    END IF;

    -- 4. Validate Doctor existence
    SELECT COUNT(*) INTO v_doctor_exists
    FROM Doctor
    WHERE DoctorID = p_doctor_id;

    IF v_doctor_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20011, 'Error: Doctor ID ' || p_doctor_id || ' does not exist in the database.');
    END IF;

    -- 5. Calculate proposed end time
    v_new_end_time := p_procedure_date + (p_duration / 1440);

    -- 6. Check for Doctor Schedule Interval Overlap
    -- Two intervals [S1, E1] and [S2, E2] overlap iff S1 < E2 AND E1 > S2
    SELECT COUNT(*)
    INTO v_doc_conflicts
    FROM MedicalProcedure
    WHERE DoctorID = p_doctor_id
      AND Outcome NOT IN ('Aborted', 'Cancelled')
      AND p_procedure_date < EndTime
      AND v_new_end_time   > ProcedureDate;

    IF v_doc_conflicts > 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Doctor Conflict: Doctor ' || p_doctor_id || 
            ' already has a procedure scheduled between ' || 
            TO_CHAR(p_procedure_date, 'HH24:MI') || ' and ' || TO_CHAR(v_new_end_time, 'HH24:MI') || '.');
    END IF;

    -- 7. Check for Operating Room Interval Overlap
    SELECT COUNT(*)
    INTO v_room_conflicts
    FROM MedicalProcedure
    WHERE OperatingRoom = p_operating_room
      AND Outcome NOT IN ('Aborted', 'Cancelled')
      AND p_procedure_date < EndTime
      AND v_new_end_time   > ProcedureDate;

    IF v_room_conflicts > 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'Operating Room Conflict: Room ' || p_operating_room || 
            ' is already occupied by another procedure during this time window.');
    END IF;

    -- 8. Insert clean procedure tuple
    INSERT INTO MedicalProcedure (
        ProcedureID,
        PatientID,
        DoctorID,
        ProcedureName,
        ProcedureDate,
        Duration,
        OperatingRoom,
        ProcedureCost,
        Outcome
    ) VALUES (
        p_procedure_id,
        p_patient_id,
        p_doctor_id,
        p_procedure_name,
        p_procedure_date,
        p_duration,
        p_operating_room,
        p_procedure_cost,
        'Successful'
    );

    DBMS_OUTPUT.PUT_LINE('Success: Procedure #' || p_procedure_id || ' (' || p_procedure_name || 
                         ') scheduled in ' || p_operating_room || ' from ' || 
                         TO_CHAR(p_procedure_date, 'HH24:MI') || ' to ' || 
                         TO_CHAR(v_new_end_time, 'HH24:MI') || '.');
END sp_schedule_procedure;
/
