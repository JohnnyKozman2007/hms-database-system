-- [POSITIVE - Min Boundaries] Duration = 1, QuantityPrescribed = 1, PrescriptionDate = 2020-01-01, 5-char Notes
BEGIN
    SAVEPOINT sp_test;
    INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes)
    VALUES ('R1', 'PAT001', 'DOC001', 'MED002', '500mg', 'Once daily', 1, 1, 'Pending', DATE '2020-01-01', 'Notes');
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
-- Expected: 1 row inserted.
