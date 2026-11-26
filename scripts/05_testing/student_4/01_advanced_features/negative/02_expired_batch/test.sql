-- [NEGATIVE] trg_rx_manage_medication_stock: Expired medication batch (ORA-20031)
BEGIN
    SAVEPOINT sp_test;

    INSERT INTO Medication (MedicationID, MedicationName, Manufacturer, Category, DosageForm, UnitPrice, QuantityInStock, ImportDate, ExpirationDate, SupplierID)
    VALUES ('MED_EXP', 'Expired Test Med', 'Pharco Pharma', 'Antibiotic', 'Tablet', 25.00, 100, DATE '2022-01-01', DATE '2023-01-01', 'SUP001');

    INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate)
    VALUES ('RX_TRG3', 'PAT002', 'DOC001', 'MED_EXP', '500mg', 'Once daily', 5, 5, 'Dispensed', TRUNC(SYSDATE));

    ROLLBACK TO sp_test;
END;
-- Expected: ORA-20031: Cannot dispense Medication MED_EXP: Batch is expired.
