-- [POSITIVE] Showcase trg_rx_manage_medication_stock: UPDATE Dispensed -> Cancelled restores stock
-- Formula: RestoredStock = AfterDispense + QuantityPrescribed (10) = BeforeStock
DECLARE
    v_before   NUMBER;
    v_disp     NUMBER;
    v_restored NUMBER;
BEGIN
    SAVEPOINT sp_test;

    SELECT QuantityInStock INTO v_before FROM Medication WHERE MedicationID = 'MED002';

    INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate)
    VALUES ('RX_TRG1', 'PAT001', 'DOC001', 'MED002', '500mg', 'Twice daily', 5, 10, 'Dispensed', TRUNC(SYSDATE));

    SELECT QuantityInStock INTO v_disp FROM Medication WHERE MedicationID = 'MED002';

    UPDATE Prescription SET DispenseStatus = 'Cancelled' WHERE PrescriptionID = 'RX_TRG1';

    SELECT QuantityInStock INTO v_restored FROM Medication WHERE MedicationID = 'MED002';
    DBMS_OUTPUT.PUT_LINE('MED002 Stock -> Before: ' || v_before || ' | Dispensed: ' || v_disp || ' | Restored: ' || v_restored);

    ROLLBACK TO sp_test;
END;
-- Expected: Stock deducts by 10 then restores to original (602 -> 592 -> 602).
