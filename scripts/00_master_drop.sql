-- HMS Master Drop Script (Oracle SQL / Oracle APEX)
-- Drops all views, triggers, procedures, functions, and tables in reverse student FK order (4 -> 5 -> 3 -> 2 -> 1).

-- 1. Views
DROP VIEW vw_doctor_dept_workload;
DROP VIEW vw_department_staff_summary;

-- 2. Triggers
DROP TRIGGER trg_doc_date_max;
DROP TRIGGER trg_nurse_date_max;
DROP TRIGGER trg_pat_dob_max;
DROP TRIGGER trg_adm_date_max;
DROP TRIGGER trg_mr_date_max;
DROP TRIGGER trg_med_import_date_max;
DROP TRIGGER trg_rx_date_max;
DROP TRIGGER trg_lab_date_max;
DROP TRIGGER trg_inv_date_max;
DROP TRIGGER trg_ins_start_date_max;
DROP TRIGGER trg_pay_date_max;
DROP TRIGGER trg_apt_date_horizon;
DROP TRIGGER trg_proc_date_horizon;
DROP TRIGGER trg_adm_sync_room_status;
DROP TRIGGER trg_rx_manage_medication_stock;
DROP TRIGGER trg_ins_status_date_guard;
DROP TRIGGER trg_inv_status_guard;
DROP TRIGGER trg_pay_check_insurance;
DROP TRIGGER trg_pay_balance_and_status;

-- 3. Stored Procedures & Functions
DROP PROCEDURE sp_validate_date_upper_bound;
DROP PROCEDURE sp_cancel_appointment;
DROP FUNCTION fn_get_patient_financial_status;
DROP FUNCTION fn_get_invoice_patient_copay;
DROP FUNCTION fn_get_patient_net_balance;

-- 4. Tables (Reverse Student FK Order: Student 4 -> Student 5 -> Student 3 -> Student 2 -> Student 1)
-- Student 4
DROP TABLE LaboratoryTest CASCADE CONSTRAINTS PURGE;
DROP TABLE Prescription CASCADE CONSTRAINTS PURGE;
DROP TABLE Medication CASCADE CONSTRAINTS PURGE;

-- Student 5
DROP TABLE Payment CASCADE CONSTRAINTS PURGE;
DROP TABLE Invoice CASCADE CONSTRAINTS PURGE;
DROP TABLE Insurance CASCADE CONSTRAINTS PURGE;
DROP TABLE Supplier CASCADE CONSTRAINTS PURGE;

-- Student 3
DROP TABLE MedicalProcedure CASCADE CONSTRAINTS PURGE;
DROP TABLE MedicalRecord CASCADE CONSTRAINTS PURGE;
DROP TABLE Appointment CASCADE CONSTRAINTS PURGE;

-- Student 2
DROP TABLE Admission CASCADE CONSTRAINTS PURGE;
DROP TABLE Room CASCADE CONSTRAINTS PURGE;
DROP TABLE Patient CASCADE CONSTRAINTS PURGE;

-- Student 1
DROP TABLE Nurse CASCADE CONSTRAINTS PURGE;
DROP TABLE Doctor CASCADE CONSTRAINTS PURGE;
DROP TABLE Department CASCADE CONSTRAINTS PURGE;
