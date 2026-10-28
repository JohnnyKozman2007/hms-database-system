-- ============================================================================
-- HOSPITAL MANAGEMENT SYSTEM (HMS) - MASTER BUILD & VERIFICATION SCRIPT
-- Module: Data Modeling for DB (4FTC2063)
-- Target: Oracle APEX / Oracle SQL Developer
-- ============================================================================

PROMPT ====================================================================
PROMPT STEP 1: Creating All 16 Tables and Constraints
PROMPT ====================================================================
@@00_master_schema.sql

PROMPT ====================================================================
PROMPT STEP 2: Inserting Foundation Seed Data
PROMPT ====================================================================
-- Student 1
@@02_seeds/student1_dept_staff/insert_department.sql
@@02_seeds/student1_dept_staff/insert_doctor.sql
@@02_seeds/student1_dept_staff/insert_nurse.sql

-- Student 5 Foundation (Supplier)
@@02_seeds/student5_finance_insurance/insert_supplier.sql

-- Student 2 Foundation (Patient, Room, Admission)
@@02_seeds/student2_patient_admission/insert_patient.sql
@@02_seeds/student2_patient_admission/insert_room.sql
@@02_seeds/student2_patient_admission/insert_admission.sql

-- Student 4 Foundation (Medication, Prescription, LabTest)
@@02_seeds/student4_pharmacy_lab/insert_medication.sql
@@02_seeds/student4_pharmacy_lab/insert_prescription.sql
@@02_seeds/student4_pharmacy_lab/insert_laboratory_test.sql

-- Student 3 Clinical (Appointment, Record, Procedure)
@@02_seeds/student3_appointments_records/insert_appointment.sql
@@02_seeds/student3_appointments_records/insert_medical_record.sql
@@02_seeds/student3_appointments_records/insert_medical_procedure.sql

-- Student 5 Finance (Insurance, Invoice, Payment)
@@02_seeds/student5_finance_insurance/insert_insurance.sql
@@02_seeds/student5_finance_insurance/insert_invoice.sql
@@02_seeds/student5_finance_insurance/insert_payment.sql

PROMPT ====================================================================
PROMPT STEP 3: Compiling Advanced Database Features
PROMPT ====================================================================
@@04_advanced_features/student1_view.sql
@@04_advanced_features/student2_trigger.sql
@@04_advanced_features/student3_stored_proc.sql
@@04_advanced_features/student4_trigger.sql
@@04_advanced_features/student5_function.sql

PROMPT ====================================================================
PROMPT HMS DATABASE BUILD COMPLETE! ALL 16 TABLES & OBJECTS READY.
PROMPT ====================================================================
