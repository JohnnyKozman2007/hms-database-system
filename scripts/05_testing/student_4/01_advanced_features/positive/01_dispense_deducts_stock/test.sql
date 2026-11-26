-- [POSITIVE] Showcase trg_rx_manage_medication_stock: INSERT Dispensed deducts stock
-- Formula: NewStock = BeforeStock - QuantityPrescribed (10)
DECLARE
    v_before NUMBER;
    v_after  NUMBER;
BEGIN
    SAVEPOINT sp_test;

    SELECT QuantityInStock INTO v_before FROM Medication WHERE MedicationID = 'MED002';

    INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate)
    VALUES ('RX_TRG1', 'PAT001', 'DOC001', 'MED002', '500mg', 'Twice daily', 5, 10, 'Dispensed', TRUNC(SYSDATE));

    SELECT QuantityInStock INTO v_after FROM Medication WHERE MedicationID = 'MED002';
    DBMS_OUTPUT.PUT_LINE('MED002 Stock -> Before: ' || v_before || ' | Dispensed: 10 | After: ' || v_after);

    ROLLBACK TO sp_test;
END;
-- Expected: After = Before - 10 (602 -> 592).
