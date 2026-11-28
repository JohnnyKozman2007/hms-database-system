-- ============================================================================
-- ORACLE APEX SQL SCRIPT: STUDENT_3
-- Upload in: Oracle APEX -> SQL Workshop -> SQL Scripts -> Upload -> Run
-- All positive DML tests use SAVEPOINT + ROLLBACK (zero permanent changes).
-- ============================================================================

-- [01] student_3\01_advanced_features\negative\01_sp_cancel_appointment_not_found
-- Expected: ORA-20001: Appointment not found: APT999
-- [NEGATIVE] sp_cancel_appointment with non-existent AppointmentID
BEGIN
    sp_cancel_appointment('APT999', 'Patient did not confirm');
END;
/

-- [02] student_3\01_advanced_features\negative\02_sp_cancel_appointment_short_reason
-- Expected: ORA-02290: check constraint (CHK_APT_NOTES_LEN) violated.
-- [NEGATIVE] sp_cancel_appointment with Notes < 5 chars
BEGIN
    sp_cancel_appointment('APT001', 'No');
END;
/

-- [03] student_3\01_advanced_features\positive\01_sp_cancel_appointment_valid
-- Expected: Status updated to 'Cancelled' and Notes saved cleanly.
-- [POSITIVE] Showcase sp_cancel_appointment (Valid Cancellation)
BEGIN
    SAVEPOINT sp_test;
    sp_cancel_appointment('APT001', 'Patient requested cancellation by phone');
    DBMS_OUTPUT.PUT_LINE('Appointment APT001 cancelled successfully.');
    ROLLBACK TO sp_test;
END;
/

-- [09] student_3\02_appointment\negative\01_invalid_appointment_id
-- [NEGATIVE] Invalid AppointmentID (chk_apt_id)
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason)
VALUES ('APT@1', 'PAT002', 'DOC002', TO_DATE('2026-12-21 09:30', 'YYYY-MM-DD HH24:MI'), 'Scheduled', 'Checkup');
-- Expected: ORA-02290: check constraint (CHK_APT_ID) violated.

-- [10] student_3\02_appointment\negative\02_invalid_patient_fk
-- [NEGATIVE] Non-existent PatientID (fk_apt_patient)
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason)
VALUES ('APT_T2', 'PAT999', 'DOC001', TO_DATE('2026-12-21 10:00', 'YYYY-MM-DD HH24:MI'), 'Scheduled', 'Checkup');
-- Expected: ORA-02291: integrity constraint (FK_APT_PATIENT) violated.

-- [11] student_3\02_appointment\negative\03_invalid_doctor_fk
-- [NEGATIVE] Non-existent DoctorID (fk_apt_doctor)
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason)
VALUES ('APT_T3', 'PAT001', 'DOC999', TO_DATE('2026-12-21 10:30', 'YYYY-MM-DD HH24:MI'), 'Scheduled', 'Checkup');
-- Expected: ORA-02291: integrity constraint (FK_APT_DOCTOR) violated.

-- [12] student_3\02_appointment\negative\04_date_before_2020
-- [NEGATIVE] AppointmentDate before 2020-01-01 on UPDATE (chk_apt_date)
UPDATE Appointment SET AppointmentDate = DATE '2019-12-31' WHERE AppointmentID = 'APT001';
-- Expected: ORA-02290: check constraint (CHK_APT_DATE) violated.

-- [13] student_3\02_appointment\negative\05_cancelled_without_notes
-- [NEGATIVE] Status = 'Cancelled' with NULL Notes on UPDATE (chk_apt_status_note)
UPDATE Appointment SET Status = 'Cancelled', Notes = NULL WHERE AppointmentID = 'APT001';
-- Expected: ORA-02290: check constraint (CHK_APT_STATUS_NOTE) violated.

-- [14] student_3\02_appointment\negative\06_invalid_status
-- [NEGATIVE] Invalid Status on UPDATE (chk_apt_status)
UPDATE Appointment SET Status = 'Delayed' WHERE AppointmentID = 'APT001';
-- Expected: ORA-02290: check constraint (CHK_APT_STATUS) violated.

-- [15] student_3\02_appointment\negative\07_reason_too_short
-- [NEGATIVE] Reason < 5 chars on UPDATE (chk_apt_reason_len)
UPDATE Appointment SET Reason = 'Pain' WHERE AppointmentID = 'APT001';
-- Expected: ORA-02290: check constraint (CHK_APT_REASON_LEN) violated.

-- [16] student_3\02_appointment\negative\08_notes_too_short
-- [NEGATIVE] Notes < 5 chars on UPDATE (chk_apt_notes_len)
UPDATE Appointment SET Notes = 'Ok' WHERE AppointmentID = 'APT001';
-- Expected: ORA-02290: check constraint (CHK_APT_NOTES_LEN) violated.

-- [16b] student_3\02_appointment\negative\09_duplicate_doctor_slot
-- [NEGATIVE] Duplicate Doctor Appointment Slot (uq_apt_doc_time)
INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes)
SELECT 'APT_DUP1', 'PAT050', DoctorID, AppointmentDate, 'Completed', 'Double booking test', 'Testing unique doctor slot'
FROM Appointment WHERE AppointmentID = 'APT002';
-- Expected: ORA-00001: unique constraint (UQ_APT_DOC_TIME) violated.

-- [17] student_3\02_appointment\positive\01_min_boundaries
-- Expected: 1 row inserted.
-- [POSITIVE - Min Boundaries] AppointmentDate = 2020-01-01, 5-char Reason & Notes
BEGIN
    SAVEPOINT sp_test;
    INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes)
    VALUES ('A1', 'PAT001', 'DOC001', DATE '2020-01-01', 'Scheduled', 'Check', 'Valid');
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
/

-- [18] student_3\02_appointment\positive\02_max_boundaries
-- Expected: 1 row inserted.
-- [POSITIVE - Max Boundaries] AppointmentDate = TRUNC(SYSDATE) + 365
BEGIN
    SAVEPOINT sp_test;
    INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, AppointmentDate, Status, Reason, Notes)
    VALUES ('APT_MAX_01', 'PAT002', 'DOC002', TRUNC(SYSDATE) + 365, 'In-Progress', 'Annual cardiology follow-up evaluation', 'Maximum horizon date test');
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
/

-- [19] student_3\02_appointment\positive\03_defaults_and_nulls
-- Expected: 1 row inserted with Status = 'Scheduled' and AppointmentDate = SYSDATE.
-- [POSITIVE - Defaults & NULLs] Omit AppointmentDate (SYSDATE) & Status ('Scheduled'); Notes = NULL
BEGIN
    SAVEPOINT sp_test;
    INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, Reason, Notes)
    VALUES ('APT_DEF_01', 'PAT003', 'DOC003', 'Routine consultation', NULL);
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
/

-- [20] student_3\02_appointment\positive\04_valid_update
-- Expected: 1 row updated.
-- [POSITIVE - Valid UPDATE] Cancel appointment with valid Notes
BEGIN
    SAVEPOINT sp_test;
    UPDATE Appointment SET Status = 'Cancelled', Notes = 'Patient requested reschedule' WHERE AppointmentID = 'APT001';
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
/

-- [21] student_3\03_medical_record\negative\01_invalid_record_id
-- [NEGATIVE] Invalid RecordID (chk_mr_id)
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, RecordDate)
VALUES ('MR*1', 'PAT001', 'DOC001', 'Hypertension', 'Lifestyle changes', DATE '2026-11-11');
-- Expected: ORA-02290: check constraint (CHK_MR_ID) violated.

-- [22] student_3\03_medical_record\negative\02_duplicate_encounter
-- [NEGATIVE] Duplicate Encounter (uq_mr_encounter)
INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, RecordDate)
SELECT 'MR_T2', PatientID, DoctorID, 'Duplicate Encounter', 'Duplicate Treatment', RecordDate
FROM MedicalRecord WHERE RecordID = 'MR001';
-- Expected: ORA-00001: unique constraint (UQ_MR_ENCOUNTER) violated.

-- [23] student_3\03_medical_record\negative\03_diagnosis_too_short
-- [NEGATIVE] Diagnosis < 5 chars on UPDATE (chk_mr_diag_len)
UPDATE MedicalRecord SET Diagnosis = 'Flu' WHERE RecordID = 'MR001';
-- Expected: ORA-02290: check constraint (CHK_MR_DIAG_LEN) violated.

-- [24] student_3\03_medical_record\negative\04_treatment_too_short
-- [NEGATIVE] Treatment < 5 chars on UPDATE (chk_mr_treat_len)
UPDATE MedicalRecord SET Treatment = 'Rest' WHERE RecordID = 'MR001';
-- Expected: ORA-02290: check constraint (CHK_MR_TREAT_LEN) violated.

-- [25] student_3\03_medical_record\negative\05_followup_before_record_date
-- [NEGATIVE] FollowUpDate earlier than RecordDate (chk_mr_dates)
UPDATE MedicalRecord SET FollowUpDate = DATE '2020-01-01' WHERE RecordID = 'MR001';
-- Expected: ORA-02290: check constraint (CHK_MR_DATES) violated.

-- [26] student_3\03_medical_record\negative\06_followup_over_365_days
-- [NEGATIVE] FollowUpDate > RecordDate + 365 (chk_mr_dates)
UPDATE MedicalRecord SET FollowUpDate = DATE '2029-01-01' WHERE RecordID = 'MR001';
-- Expected: ORA-02290: check constraint (CHK_MR_DATES) violated.

-- [27] student_3\03_medical_record\positive\01_min_boundaries
-- Expected: 1 row inserted.
-- [POSITIVE - Min Boundaries] RecordDate = 2020-01-01, FollowUpDate = RecordDate, 5-char strings
BEGIN
    SAVEPOINT sp_test;
    INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate)
    VALUES ('M1', 'PAT001', 'DOC001', 'Fever', 'Fluids', 'Notes', DATE '2020-01-01', DATE '2020-01-01');
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
/

-- [28] student_3\03_medical_record\positive\02_max_boundaries
-- Expected: 1 row inserted.
-- [POSITIVE - Max Boundaries] RecordDate = TRUNC(SYSDATE), FollowUpDate = RecordDate + 365
BEGIN
    SAVEPOINT sp_test;
    INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, RecordDate, FollowUpDate)
    VALUES ('MR_MAX_01', 'PAT002', 'DOC002', 'Essential Hypertension', 'Daily ACE inhibitor therapy', '1-year follow-up boundary', TRUNC(SYSDATE), TRUNC(SYSDATE) + 365);
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
/

-- [29] student_3\03_medical_record\positive\03_defaults_and_nulls
-- Expected: 1 row inserted with RecordDate = SYSDATE.
-- [POSITIVE - Defaults & NULLs] Omit RecordDate (SYSDATE); Notes = NULL, FollowUpDate = NULL
BEGIN
    SAVEPOINT sp_test;
    INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, FollowUpDate)
    VALUES ('MR_DEF_01', 'PAT003', 'DOC003', 'Seasonal Allergic Rhinitis', 'Antihistamine nasal spray', NULL, NULL);
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
/

-- [30] student_3\03_medical_record\positive\04_valid_update
-- Expected: 1 row updated.
-- [POSITIVE - Valid UPDATE] Update Diagnosis & Treatment
BEGIN
    SAVEPOINT sp_test;
    UPDATE MedicalRecord SET Diagnosis = 'Controlled Hypertension', Treatment = 'Continue low-dose ACE inhibitor' WHERE RecordID = 'MR001';
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
/

-- [31] student_3\04_medical_procedure\negative\01_invalid_procedure_id
-- [NEGATIVE] Invalid ProcedureID (chk_proc_id)
INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, ProcedureDate, Duration, OperatingRoom, ProcedureCost)
VALUES ('PROC/1', 'PAT002', 'DOC002', 'Appendectomy', TO_DATE('2026-12-23 12:00', 'YYYY-MM-DD HH24:MI'), 60, 'OR-1', 10000.00);
-- Expected: ORA-02290: check constraint (CHK_PROC_ID) violated.

-- [32] student_3\04_medical_procedure\negative\02_procedure_name_too_short
-- [NEGATIVE] ProcedureName < 5 chars on UPDATE (chk_proc_name_len)
UPDATE MedicalProcedure SET ProcedureName = 'Scan' WHERE ProcedureID = 'PROC001';
-- Expected: ORA-02290: check constraint (CHK_PROC_NAME_LEN) violated.

-- [33] student_3\04_medical_procedure\negative\03_duration_zero
-- [NEGATIVE] Duration = 0 on UPDATE (chk_proc_duration)
UPDATE MedicalProcedure SET Duration = 0 WHERE ProcedureID = 'PROC001';
-- Expected: ORA-02290: check constraint (CHK_PROC_DURATION) violated.

-- [34] student_3\04_medical_procedure\negative\04_invalid_operating_room
-- [NEGATIVE] Invalid OperatingRoom on UPDATE (chk_proc_room)
UPDATE MedicalProcedure SET OperatingRoom = 'Room 101' WHERE ProcedureID = 'PROC001';
-- Expected: ORA-02290: check constraint (CHK_PROC_ROOM) violated.

-- [35] student_3\04_medical_procedure\negative\05_negative_cost
-- [NEGATIVE] Negative ProcedureCost on UPDATE (chk_proc_cost)
UPDATE MedicalProcedure SET ProcedureCost = -100 WHERE ProcedureID = 'PROC001';
-- Expected: ORA-02290: check constraint (CHK_PROC_COST) violated.

-- [36] student_3\04_medical_procedure\negative\06_invalid_outcome
-- [NEGATIVE] Invalid Outcome on UPDATE (chk_proc_outcome)
UPDATE MedicalProcedure SET Outcome = 'Done' WHERE ProcedureID = 'PROC001';
-- Expected: ORA-02290: check constraint (CHK_PROC_OUTCOME) violated.

-- [37] student_3\04_medical_procedure\positive\01_min_boundaries
-- Expected: 1 row inserted.
-- [POSITIVE - Min Boundaries] ProcedureDate = 2020-01-01, Duration = 1, ProcedureCost = 0.01, 5-char name
BEGIN
    SAVEPOINT sp_test;
    INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, ProcedureDate, Duration, OperatingRoom, ProcedureCost, Outcome)
    VALUES ('P1', 'PAT001', 'DOC001', 'Biops', DATE '2020-01-01', 1, 'OR-1', 0.01, 'Pending');
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
/

-- [38] student_3\04_medical_procedure\positive\02_max_boundaries
-- Expected: 1 row inserted.
-- [POSITIVE - Max Boundaries] ProcedureDate = TRUNC(SYSDATE) + 365, Duration = 1440, ProcedureCost = 1000000.00
BEGIN
    SAVEPOINT sp_test;
    INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, ProcedureDate, Duration, OperatingRoom, ProcedureCost, Outcome)
    VALUES ('PROC_MAX_1', 'PAT002', 'DOC002', 'Complex Cardiothoracic Reconstruction', TRUNC(SYSDATE) + 365, 1440, 'Cath Lab', 1000000.00, 'Successful');
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
/

-- [39] student_3\04_medical_procedure\positive\03_defaults_and_nulls
-- Expected: 1 row inserted with ProcedureDate = SYSDATE and Outcome = 'Pending'.
-- [POSITIVE - Defaults] Omit ProcedureDate (SYSDATE) & Outcome ('Pending')
BEGIN
    SAVEPOINT sp_test;
    INSERT INTO MedicalProcedure (ProcedureID, PatientID, DoctorID, ProcedureName, Duration, OperatingRoom, ProcedureCost)
    VALUES ('PROC_DEF_1', 'PAT003', 'DOC003', 'Diagnostic Endoscopy', 30, 'Endoscopy Suite', 2500.00);
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
/

-- [40] student_3\04_medical_procedure\positive\04_valid_update
-- Expected: 1 row updated.
-- [POSITIVE - Valid UPDATE] Update Outcome & ProcedureCost
BEGIN
    SAVEPOINT sp_test;
    UPDATE MedicalProcedure SET Outcome = 'Successful', ProcedureCost = 20000.00 WHERE ProcedureID = 'PROC001';
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
/
