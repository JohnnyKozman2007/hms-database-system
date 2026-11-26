-- [POSITIVE - Max Boundaries] Duration = 365, QuantityPrescribed = 500 (Dispensed within MED002 stock), PrescriptionDate = TRUNC(SYSDATE)
BEGIN
    SAVEPOINT sp_test;
    INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes)
    VALUES ('RX_MAX_01', 'PAT002', 'DOC002', 'MED002', '500mg', 'Three times daily', 365, 500, 'Dispensed', TRUNC(SYSDATE), 'Max duration and large quantity test');
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
-- Expected: 1 row inserted.
