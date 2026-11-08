-- ============================================================================
-- ADVANCED DATABASE FEATURE: Student 3
-- Stored Procedures & Automatic Backstop Triggers: Complete Conflict-Free Engine
-- Module: Data Modeling for DB (4FTC2063)
-- Subsystem: Appointments and Medical Records
-- ============================================================================
-- Architecture (Two-Layer Defense-in-Depth):
-- 1. Front-Door Application Layer (Stored Procedures):
--    - sp_book_appointment: Validates existence and books clean appointments.
--    - sp_schedule_procedure: Calculates interval end-times and validates availability.
-- 2. Engine-Level Backstop Layer (Compound Triggers):
--    - trg_procedure_overlap_guard: Blocks rogue raw INSERT/UPDATE interval collisions.
--    - trg_appointment_conflict_guard: Blocks rogue raw INSERT/UPDATE appointment collisions.
-- (Compound triggers eliminate ORA-04091 mutating table errors in Oracle SQL).
-- ============================================================================

SET SERVEROUTPUT ON;

-- ----------------------------------------------------------------------------
-- 1. PROCEDURE: sp_book_appointment
-- Description: Books an appointment, ensuring neither the Doctor nor the Patient
--              already has an active scheduled appointment at the exact requested time.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE sp_book_appointment (
    p_appointment_id   IN NUMBER,
    p_patient_id       IN NUMBER,
    p_doctor_id        IN NUMBER,
    p_appointment_date IN DATE,
    p_reason           IN VARCHAR2,
    p_notes            IN VARCHAR2 DEFAULT NULL
) IS
    v_patient_exists      NUMBER := 0;
    v_doctor_exists       NUMBER := 0;
    v_doc_conflict_count  NUMBER := 0;
    v_pat_conflict_count  NUMBER := 0;
    v_time_str            VARCHAR2(5);
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
    INTO v_doc_conflict_count
    FROM Appointment
    WHERE DoctorID = p_doctor_id
      AND TRUNC(AppointmentDate) = TRUNC(p_appointment_date)
      AND AppointmentTime = v_time_str
      AND Status IN ('Scheduled', 'In-Progress');

    IF v_doc_conflict_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Booking Conflict: Doctor ' || p_doctor_id || 
            ' already has an active appointment at ' || TO_CHAR(p_appointment_date, 'YYYY-MM-DD HH24:MI') || '.');
    END IF;

    -- 5. Check for active appointment conflict for the patient
    SELECT COUNT(*)
    INTO v_pat_conflict_count
    FROM Appointment
    WHERE PatientID = p_patient_id
      AND TRUNC(AppointmentDate) = TRUNC(p_appointment_date)
      AND AppointmentTime = v_time_str
      AND Status IN ('Scheduled', 'In-Progress');

    IF v_pat_conflict_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20005, 'Booking Conflict: Patient ' || p_patient_id || 
            ' already has an active appointment at ' || TO_CHAR(p_appointment_date, 'YYYY-MM-DD HH24:MI') || '.');
    END IF;

    -- 6. Insert clean appointment tuple
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
--              the Doctor, the Operating Room, nor the Patient has an overlapping time window.
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
    v_patient_exists   NUMBER := 0;
    v_doctor_exists    NUMBER := 0;
    v_doc_conflicts    NUMBER := 0;
    v_room_conflicts   NUMBER := 0;
    v_pat_conflicts    NUMBER := 0;
    v_new_end_time     DATE;
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

    -- 8. Check for Patient Schedule Interval Overlap
    SELECT COUNT(*)
    INTO v_pat_conflicts
    FROM MedicalProcedure
    WHERE PatientID = p_patient_id
      AND Outcome NOT IN ('Aborted', 'Cancelled')
      AND p_procedure_date < EndTime
      AND v_new_end_time   > ProcedureDate;

    IF v_pat_conflicts > 0 THEN
        RAISE_APPLICATION_ERROR(-20004, 'Patient Conflict: Patient ' || p_patient_id || 
            ' is already undergoing another procedure during this time window.');
    END IF;

    -- 9. Insert clean procedure tuple with initial 'Pending' state
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
        'Pending'
    );

    DBMS_OUTPUT.PUT_LINE('Success: Procedure #' || p_procedure_id || ' (' || p_procedure_name || 
                         ') scheduled in ' || p_operating_room || ' from ' || 
                         TO_CHAR(p_procedure_date, 'HH24:MI') || ' to ' || 
                         TO_CHAR(v_new_end_time, 'HH24:MI') || '.');
END sp_schedule_procedure;
/

-- ============================================================================
-- 3. COMPOUND TRIGGER: trg_procedure_overlap_guard
-- Description: Un-bypassable database engine backstop for MedicalProcedure.
--              Guarantees that even if someone bypasses the stored procedure and
--              runs a raw SQL INSERT or UPDATE directly on MedicalProcedure,
--              time-interval overlaps for Doctor, Operating Room, and Patient
--              are automatically blocked with an application error.
-- Architecture: Compound Trigger pattern (eliminates ORA-04091 mutating table error).
-- ============================================================================
CREATE OR REPLACE TRIGGER trg_procedure_overlap_guard
FOR INSERT OR UPDATE ON MedicalProcedure
COMPOUND TRIGGER

    TYPE r_proc_record IS RECORD (
        procedure_id   NUMBER,
        patient_id     NUMBER,
        doctor_id      NUMBER,
        room           VARCHAR2(30),
        start_date     DATE,
        end_date       DATE,
        outcome        VARCHAR2(30)
    );
    TYPE t_proc_table IS TABLE OF r_proc_record;
    g_procs t_proc_table := t_proc_table();

    BEFORE STATEMENT IS
    BEGIN
        g_procs.DELETE;
    END BEFORE STATEMENT;

    BEFORE EACH ROW IS
    BEGIN
        g_procs.EXTEND;
        g_procs(g_procs.LAST).procedure_id := :NEW.ProcedureID;
        g_procs(g_procs.LAST).patient_id   := :NEW.PatientID;
        g_procs(g_procs.LAST).doctor_id    := :NEW.DoctorID;
        g_procs(g_procs.LAST).room         := :NEW.OperatingRoom;
        g_procs(g_procs.LAST).start_date   := :NEW.ProcedureDate;
        g_procs(g_procs.LAST).end_date     := :NEW.ProcedureDate + (:NEW.Duration / 1440);
        g_procs(g_procs.LAST).outcome      := :NEW.Outcome;
    END BEFORE EACH ROW;

    AFTER STATEMENT IS
        v_doc_conflicts  NUMBER := 0;
        v_room_conflicts NUMBER := 0;
        v_pat_conflicts  NUMBER := 0;
    BEGIN
        FOR i IN 1 .. g_procs.COUNT LOOP
            IF g_procs(i).outcome NOT IN ('Aborted', 'Cancelled') THEN
                -- 1. Doctor Interval Collision Check
                SELECT COUNT(*)
                INTO v_doc_conflicts
                FROM MedicalProcedure
                WHERE DoctorID = g_procs(i).doctor_id
                  AND ProcedureID <> NVL(g_procs(i).procedure_id, -1)
                  AND Outcome NOT IN ('Aborted', 'Cancelled')
                  AND g_procs(i).start_date < EndTime
                  AND g_procs(i).end_date   > ProcedureDate;

                IF v_doc_conflicts > 0 THEN
                    RAISE_APPLICATION_ERROR(-20002, 'Rogue DML Blocked: Doctor already has an active procedure scheduled in this time interval.');
                END IF;

                -- 2. Operating Room Collision Check
                SELECT COUNT(*)
                INTO v_room_conflicts
                FROM MedicalProcedure
                WHERE OperatingRoom = g_procs(i).room
                  AND ProcedureID <> NVL(g_procs(i).procedure_id, -1)
                  AND Outcome NOT IN ('Aborted', 'Cancelled')
                  AND g_procs(i).start_date < EndTime
                  AND g_procs(i).end_date   > ProcedureDate;

                IF v_room_conflicts > 0 THEN
                    RAISE_APPLICATION_ERROR(-20003, 'Rogue DML Blocked: Operating Room is already occupied in this time interval.');
                END IF;

                -- 3. Patient Collision Check
                SELECT COUNT(*)
                INTO v_pat_conflicts
                FROM MedicalProcedure
                WHERE PatientID = g_procs(i).patient_id
                  AND ProcedureID <> NVL(g_procs(i).procedure_id, -1)
                  AND Outcome NOT IN ('Aborted', 'Cancelled')
                  AND g_procs(i).start_date < EndTime
                  AND g_procs(i).end_date   > ProcedureDate;

                IF v_pat_conflicts > 0 THEN
                    RAISE_APPLICATION_ERROR(-20004, 'Rogue DML Blocked: Patient is already scheduled for another procedure in this time interval.');
                END IF;
            END IF;
        END LOOP;
    END AFTER STATEMENT;

END trg_procedure_overlap_guard;
/

-- ============================================================================
-- 4. COMPOUND TRIGGER: trg_appointment_conflict_guard
-- Description: Un-bypassable database engine backstop for Appointment.
--              Guarantees that even if someone runs a raw SQL INSERT or UPDATE
--              directly on Appointment, a Doctor cannot have two active
--              appointments ('Scheduled' or 'In-Progress') at the exact same minute.
-- ============================================================================
CREATE OR REPLACE TRIGGER trg_appointment_conflict_guard
FOR INSERT OR UPDATE ON Appointment
COMPOUND TRIGGER

    TYPE r_apt_record IS RECORD (
        appointment_id NUMBER,
        doctor_id      NUMBER,
        patient_id     NUMBER,
        apt_date       DATE,
        status         VARCHAR2(20)
    );
    TYPE t_apt_table IS TABLE OF r_apt_record;
    g_apts t_apt_table := t_apt_table();

    BEFORE STATEMENT IS
    BEGIN
        g_apts.DELETE;
    END BEFORE STATEMENT;

    BEFORE EACH ROW IS
    BEGIN
        g_apts.EXTEND;
        g_apts(g_apts.LAST).appointment_id := :NEW.AppointmentID;
        g_apts(g_apts.LAST).doctor_id      := :NEW.DoctorID;
        g_apts(g_apts.LAST).patient_id     := :NEW.PatientID;
        g_apts(g_apts.LAST).apt_date       := :NEW.AppointmentDate;
        g_apts(g_apts.LAST).status         := :NEW.Status;
    END BEFORE EACH ROW;

    AFTER STATEMENT IS
        v_doc_conflicts NUMBER := 0;
        v_pat_conflicts NUMBER := 0;
    BEGIN
        FOR i IN 1 .. g_apts.COUNT LOOP
            IF g_apts(i).status IN ('Scheduled', 'In-Progress') THEN
                -- Doctor Conflict
                SELECT COUNT(*)
                INTO v_doc_conflicts
                FROM Appointment
                WHERE DoctorID = g_apts(i).doctor_id
                  AND AppointmentID <> NVL(g_apts(i).appointment_id, -1)
                  AND Status IN ('Scheduled', 'In-Progress')
                  AND TRUNC(AppointmentDate) = TRUNC(g_apts(i).apt_date)
                  AND TO_CHAR(AppointmentDate, 'HH24:MI') = TO_CHAR(g_apts(i).apt_date, 'HH24:MI');

                IF v_doc_conflicts > 0 THEN
                    RAISE_APPLICATION_ERROR(-20001, 'Rogue DML Blocked: Doctor already has an active appointment at this date and time.');
                END IF;

                -- Patient Conflict
                SELECT COUNT(*)
                INTO v_pat_conflicts
                FROM Appointment
                WHERE PatientID = g_apts(i).patient_id
                  AND AppointmentID <> NVL(g_apts(i).appointment_id, -1)
                  AND Status IN ('Scheduled', 'In-Progress')
                  AND TRUNC(AppointmentDate) = TRUNC(g_apts(i).apt_date)
                  AND TO_CHAR(AppointmentDate, 'HH24:MI') = TO_CHAR(g_apts(i).apt_date, 'HH24:MI');

                IF v_pat_conflicts > 0 THEN
                    RAISE_APPLICATION_ERROR(-20005, 'Rogue DML Blocked: Patient already has an active appointment at this date and time.');
                END IF;
            END IF;
        END LOOP;
    END AFTER STATEMENT;

END trg_appointment_conflict_guard;
/
