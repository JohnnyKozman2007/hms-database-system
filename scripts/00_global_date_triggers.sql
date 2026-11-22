CREATE OR REPLACE PROCEDURE sp_validate_date_upper_bound (
    p_date           IN DATE,
    p_max_days_ahead IN NUMBER,
    p_column_label   IN VARCHAR2
) IS
BEGIN
    IF p_date IS NOT NULL AND p_date > SYSDATE + p_max_days_ahead THEN
        IF p_max_days_ahead = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, p_column_label || ' cannot be in the future (exceeds SYSDATE).');
        ELSE
            RAISE_APPLICATION_ERROR(-20001, p_column_label || ' cannot be more than ' || p_max_days_ahead || ' days in the future.');
        END IF;
    END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_doc_date_max
BEFORE INSERT OR UPDATE OF HireDate ON Doctor
FOR EACH ROW
BEGIN
    sp_validate_date_upper_bound(:NEW.HireDate, 0, 'Doctor.HireDate');
END;
/

CREATE OR REPLACE TRIGGER trg_nurse_date_max
BEFORE INSERT OR UPDATE OF HireDate ON Nurse
FOR EACH ROW
BEGIN
    sp_validate_date_upper_bound(:NEW.HireDate, 0, 'Nurse.HireDate');
END;
/

CREATE OR REPLACE TRIGGER trg_pat_dob_max
BEFORE INSERT OR UPDATE OF DateOfBirth ON Patient
FOR EACH ROW
BEGIN
    sp_validate_date_upper_bound(:NEW.DateOfBirth, 0, 'Patient.DateOfBirth');
END;
/

CREATE OR REPLACE TRIGGER trg_adm_date_max
BEFORE INSERT OR UPDATE OF AdmissionDate, DischargeDate ON Admission
FOR EACH ROW
BEGIN
    sp_validate_date_upper_bound(:NEW.AdmissionDate, 0, 'Admission.AdmissionDate');
    sp_validate_date_upper_bound(:NEW.DischargeDate, 0, 'Admission.DischargeDate');
END;
/

CREATE OR REPLACE TRIGGER trg_mr_date_max
BEFORE INSERT OR UPDATE OF RecordDate ON MedicalRecord
FOR EACH ROW
BEGIN
    sp_validate_date_upper_bound(:NEW.RecordDate, 0, 'MedicalRecord.RecordDate');
END;
/

CREATE OR REPLACE TRIGGER trg_med_import_date_max
BEFORE INSERT OR UPDATE OF ImportDate ON Medication
FOR EACH ROW
BEGIN
    sp_validate_date_upper_bound(:NEW.ImportDate, 0, 'Medication.ImportDate');
END;
/

CREATE OR REPLACE TRIGGER trg_rx_date_max
BEFORE INSERT OR UPDATE OF PrescriptionDate ON Prescription
FOR EACH ROW
BEGIN
    sp_validate_date_upper_bound(:NEW.PrescriptionDate, 0, 'Prescription.PrescriptionDate');
END;
/

CREATE OR REPLACE TRIGGER trg_lab_date_max
BEFORE INSERT OR UPDATE OF RequestedDate, CompletedDate ON LaboratoryTest
FOR EACH ROW
BEGIN
    sp_validate_date_upper_bound(:NEW.RequestedDate, 0, 'LaboratoryTest.RequestedDate');
    sp_validate_date_upper_bound(:NEW.CompletedDate, 0, 'LaboratoryTest.CompletedDate');
END;
/

CREATE OR REPLACE TRIGGER trg_inv_date_max
BEFORE INSERT OR UPDATE OF InvoiceDate ON Invoice
FOR EACH ROW
BEGIN
    sp_validate_date_upper_bound(:NEW.InvoiceDate, 0, 'Invoice.InvoiceDate');
END;
/

CREATE OR REPLACE TRIGGER trg_ins_start_date_max
BEFORE INSERT OR UPDATE OF StartDate ON Insurance
FOR EACH ROW
BEGIN
    sp_validate_date_upper_bound(:NEW.StartDate, 0, 'Insurance.StartDate');
END;
/

CREATE OR REPLACE TRIGGER trg_pay_date_max
BEFORE INSERT OR UPDATE OF PaymentDate ON Payment
FOR EACH ROW
BEGIN
    sp_validate_date_upper_bound(:NEW.PaymentDate, 0, 'Payment.PaymentDate');
END;
/

CREATE OR REPLACE TRIGGER trg_apt_date_horizon
BEFORE INSERT OR UPDATE OF AppointmentDate ON Appointment
FOR EACH ROW
BEGIN
    sp_validate_date_upper_bound(:NEW.AppointmentDate, 365, 'Appointment.AppointmentDate');
END;
/

CREATE OR REPLACE TRIGGER trg_proc_date_horizon
BEFORE INSERT OR UPDATE OF ProcedureDate ON MedicalProcedure
FOR EACH ROW
BEGIN
    sp_validate_date_upper_bound(:NEW.ProcedureDate, 365, 'MedicalProcedure.ProcedureDate');
END;
/
