-- ============================================================================
-- ORACLE APEX SQL SCRIPT: SHARED_ADVANCED_FEATURES
-- Upload in: Oracle APEX -> SQL Workshop -> SQL Scripts -> Upload -> Run
-- All positive DML tests use SAVEPOINT + ROLLBACK (zero permanent changes).
-- ============================================================================

-- [01] shared_advanced_features\negative\01_doctor_future_hiredate
-- [NEGATIVE] Future Doctor.HireDate (trg_doc_date_max)
UPDATE Doctor SET HireDate = SYSDATE + 5 WHERE DoctorID = 'DOC001';
-- Expected: ORA-20001: Doctor.HireDate cannot be in the future (exceeds SYSDATE).

-- [02] shared_advanced_features\negative\02_nurse_future_hiredate
-- [NEGATIVE] Future Nurse.HireDate (trg_nurse_date_max)
UPDATE Nurse SET HireDate = SYSDATE + 2 WHERE NurseID = 'NRS001';
-- Expected: ORA-20001: Nurse.HireDate cannot be in the future (exceeds SYSDATE).

-- [03] shared_advanced_features\negative\03_patient_future_dob
-- [NEGATIVE] Future Patient.DateOfBirth (trg_pat_dob_max)
UPDATE Patient SET DateOfBirth = SYSDATE + 10 WHERE PatientID = 'PAT001';
-- Expected: ORA-20001: Patient.DateOfBirth cannot be in the future (exceeds SYSDATE).

-- [04] shared_advanced_features\negative\04_admission_future_date
-- [NEGATIVE] Future Admission.AdmissionDate (trg_adm_date_max)
UPDATE Admission SET AdmissionDate = SYSDATE + 3 WHERE AdmissionID = 'ADM001';
-- Expected: ORA-20001: Admission.AdmissionDate cannot be in the future (exceeds SYSDATE).

-- [05] shared_advanced_features\negative\05_medical_record_future_date
-- [NEGATIVE] Future MedicalRecord.RecordDate (trg_mr_date_max)
UPDATE MedicalRecord SET RecordDate = SYSDATE + 1 WHERE RecordID = 'MR001';
-- Expected: ORA-20001: MedicalRecord.RecordDate cannot be in the future (exceeds SYSDATE).

-- [06] shared_advanced_features\negative\06_appointment_beyond_365_days
-- [NEGATIVE] Appointment.AppointmentDate > SYSDATE + 365 (trg_apt_date_horizon)
UPDATE Appointment SET AppointmentDate = SYSDATE + 366 WHERE AppointmentID = 'APT001';
-- Expected: ORA-20001: Appointment.AppointmentDate cannot be more than 365 days in the future.

-- [07] shared_advanced_features\negative\07_procedure_beyond_365_days
-- [NEGATIVE] MedicalProcedure.ProcedureDate > SYSDATE + 365 (trg_proc_date_horizon)
UPDATE MedicalProcedure SET ProcedureDate = SYSDATE + 400 WHERE ProcedureID = 'PROC001';
-- Expected: ORA-20001: MedicalProcedure.ProcedureDate cannot be more than 365 days in the future.

-- [08] shared_advanced_features\negative\08_medication_future_import_date
-- [NEGATIVE] Future Medication.ImportDate (trg_med_import_date_max)
UPDATE Medication SET ImportDate = SYSDATE + 1 WHERE MedicationID = 'MED002';
-- Expected: ORA-20001: Medication.ImportDate cannot be in the future (exceeds SYSDATE).

-- [09] shared_advanced_features\negative\09_prescription_future_date
-- [NEGATIVE] Future Prescription.PrescriptionDate (trg_rx_date_max)
UPDATE Prescription SET PrescriptionDate = SYSDATE + 1 WHERE PrescriptionID = 'RX001';
-- Expected: ORA-20001: Prescription.PrescriptionDate cannot be in the future (exceeds SYSDATE).

-- [10] shared_advanced_features\negative\10_lab_future_requested_date
-- [NEGATIVE] Future LaboratoryTest.RequestedDate (trg_lab_date_max)
UPDATE LaboratoryTest SET RequestedDate = SYSDATE + 1 WHERE TestID = 'LAB001';
-- Expected: ORA-20001: LaboratoryTest.RequestedDate cannot be in the future (exceeds SYSDATE).

-- [11] shared_advanced_features\negative\11_invoice_future_date
-- [NEGATIVE] Future Invoice.InvoiceDate (trg_inv_date_max)
UPDATE Invoice SET InvoiceDate = SYSDATE + 1 WHERE InvoiceID = 'INV001';
-- Expected: ORA-20001: Invoice.InvoiceDate cannot be in the future (exceeds SYSDATE).

-- [12] shared_advanced_features\negative\12_insurance_future_start_date
-- [NEGATIVE] Future Insurance.StartDate (trg_ins_start_date_max)
UPDATE Insurance SET StartDate = SYSDATE + 1 WHERE InsuranceID = 'INS001';
-- Expected: ORA-20001: Insurance.StartDate cannot be in the future (exceeds SYSDATE).

-- [13] shared_advanced_features\negative\13_payment_future_date
-- [NEGATIVE] Future Payment.PaymentDate (trg_pay_date_max)
UPDATE Payment SET PaymentDate = SYSDATE + 1 WHERE PaymentID = 'PAY001';
-- Expected: ORA-20001: Payment.PaymentDate cannot be in the future (exceeds SYSDATE).

-- [14] shared_advanced_features\positive\01_doctor_hiredate_sysdate
-- Expected: 1 row updated.
-- [POSITIVE] Boundary: Doctor.HireDate = TRUNC(SYSDATE)
BEGIN
    SAVEPOINT sp_test;
    UPDATE Doctor SET HireDate = TRUNC(SYSDATE) WHERE DoctorID = 'DOC001';
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
/

-- [15] shared_advanced_features\positive\02_appointment_date_365_horizon
-- Expected: 1 row updated.
-- [POSITIVE] Boundary: Appointment.AppointmentDate within 365-day horizon
BEGIN
    SAVEPOINT sp_test;
    UPDATE Appointment SET AppointmentDate = TRUNC(SYSDATE) + 300 + (10/24) WHERE AppointmentID = 'APT001';
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
/

-- [16] shared_advanced_features\positive\03_procedure_date_365_horizon
-- Expected: 1 row updated.
-- [POSITIVE] Boundary: MedicalProcedure.ProcedureDate within 365-day horizon
BEGIN
    SAVEPOINT sp_test;
    UPDATE MedicalProcedure SET ProcedureDate = TRUNC(SYSDATE) + 300 + (11/24) WHERE ProcedureID = 'PROC001';
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
/
