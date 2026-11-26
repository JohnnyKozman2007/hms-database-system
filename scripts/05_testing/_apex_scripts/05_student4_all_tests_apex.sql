-- ============================================================================
-- ORACLE APEX SQL SCRIPT: STUDENT_4
-- Upload in: Oracle APEX -> SQL Workshop -> SQL Scripts -> Upload -> Run
-- All positive DML tests use SAVEPOINT + ROLLBACK (zero permanent changes).
-- ============================================================================

-- [01] student_4\01_advanced_features\negative\01_insufficient_stock
-- [NEGATIVE] trg_rx_manage_medication_stock: Insufficient stock (ORA-20030)
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate)
VALUES ('RX_TRG2', 'PAT002', 'DOC001', 'MED002', '500mg', 'Once daily', 30, 999, 'Dispensed', TRUNC(SYSDATE));
-- Expected: ORA-20030: Insufficient stock for Medication MED002.

-- [02] student_4\01_advanced_features\negative\02_expired_batch
-- Expected: ORA-20031: Cannot dispense Medication MED_EXP: Batch is expired.
-- [NEGATIVE] trg_rx_manage_medication_stock: Expired medication batch (ORA-20031)
BEGIN
    SAVEPOINT sp_test;

    INSERT INTO Medication (MedicationID, MedicationName, Manufacturer, Category, DosageForm, UnitPrice, QuantityInStock, ImportDate, ExpirationDate, SupplierID)
    VALUES ('MED_EXP', 'Expired Test Med', 'Pharco Pharma', 'Antibiotic', 'Tablet', 25.00, 100, DATE '2022-01-01', DATE '2023-01-01', 'SUP001');

    INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate)
    VALUES ('RX_TRG3', 'PAT002', 'DOC001', 'MED_EXP', '500mg', 'Once daily', 5, 5, 'Dispensed', TRUNC(SYSDATE));

    ROLLBACK TO sp_test;
END;
/

-- [03] student_4\01_advanced_features\positive\01_dispense_deducts_stock
-- Expected: After = Before - 10 (602 -> 592).
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
/

-- [04] student_4\01_advanced_features\positive\02_cancel_restores_stock
-- Expected: Stock deducts by 10 then restores to original (602 -> 592 -> 602).
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
/

-- [05] student_4\02_medication\negative\01_invalid_medication_id
-- [NEGATIVE] Invalid MedicationID (chk_med_id)
INSERT INTO Medication (MedicationID, MedicationName, Manufacturer, Category, DosageForm, UnitPrice, QuantityInStock, ImportDate, ExpirationDate, SupplierID)
VALUES ('MED@1', 'Valid Name', 'Valid Mfg', 'Antibiotic', 'Tablet', 10.00, 10, DATE '2025-06-01', DATE '2028-06-01', 'SUP001');
-- Expected: ORA-02290: check constraint (CHK_MED_ID) violated.

-- [06] student_4\02_medication\negative\02_name_too_short
-- [NEGATIVE] MedicationName < 5 chars on UPDATE (chk_med_name_len)
UPDATE Medication SET MedicationName = 'Med' WHERE MedicationID = 'MED002';
-- Expected: ORA-02290: check constraint (CHK_MED_NAME_LEN) violated.

-- [07] student_4\02_medication\negative\03_manufacturer_too_short
-- [NEGATIVE] Manufacturer < 5 chars on UPDATE (chk_med_mfg_len)
UPDATE Medication SET Manufacturer = 'ABC' WHERE MedicationID = 'MED002';
-- Expected: ORA-02290: check constraint (CHK_MED_MFG_LEN) violated.

-- [08] student_4\02_medication\negative\04_invalid_category
-- [NEGATIVE] Invalid Category on UPDATE (chk_med_category)
UPDATE Medication SET Category = 'Vitamin' WHERE MedicationID = 'MED002';
-- Expected: ORA-02290: check constraint (CHK_MED_CATEGORY) violated.

-- [09] student_4\02_medication\negative\05_invalid_dosage_form
-- [NEGATIVE] Invalid DosageForm on UPDATE (chk_med_dosage_form)
UPDATE Medication SET DosageForm = 'Powder' WHERE MedicationID = 'MED002';
-- Expected: ORA-02290: check constraint (CHK_MED_DOSAGE_FORM) violated.

-- [10] student_4\02_medication\negative\06_unit_price_zero
-- [NEGATIVE] UnitPrice <= 0 on UPDATE (chk_med_unit_price)
UPDATE Medication SET UnitPrice = 0 WHERE MedicationID = 'MED002';
-- Expected: ORA-02290: check constraint (CHK_MED_UNIT_PRICE) violated.

-- [11] student_4\02_medication\negative\07_negative_stock
-- [NEGATIVE] Negative QuantityInStock on UPDATE (chk_med_stock)
UPDATE Medication SET QuantityInStock = -5 WHERE MedicationID = 'MED002';
-- Expected: ORA-02290: check constraint (CHK_MED_STOCK) violated.

-- [12] student_4\02_medication\negative\08_expiration_before_import
-- [NEGATIVE] ExpirationDate <= ImportDate on UPDATE (chk_med_dates)
UPDATE Medication SET ExpirationDate = DATE '2020-01-01' WHERE MedicationID = 'MED002';
-- Expected: ORA-02290: check constraint (CHK_MED_DATES) violated.

-- [13] student_4\02_medication\negative\09_invalid_supplier_fk
-- [NEGATIVE] Non-existent SupplierID on UPDATE (fk_med_supplier)
UPDATE Medication SET SupplierID = 'SUP999' WHERE MedicationID = 'MED002';
-- Expected: ORA-02291: integrity constraint (FK_MED_SUPPLIER) violated.

-- [14] student_4\02_medication\positive\01_min_boundaries
-- Expected: 1 row inserted.
-- [POSITIVE - Min Boundaries] UnitPrice = 0.01, QuantityInStock = 0, ImportDate = 2020-01-01, 5-char strings
BEGIN
    SAVEPOINT sp_test;
    INSERT INTO Medication (MedicationID, MedicationName, Manufacturer, Category, DosageForm, UnitPrice, QuantityInStock, ImportDate, ExpirationDate, SupplierID)
    VALUES ('M1', 'MedA1', 'MfgA1', 'Other', 'Drops', 0.01, 0, DATE '2020-01-01', DATE '2020-01-02', 'SUP001');
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
/

-- [15] student_4\02_medication\positive\02_max_boundaries
-- Expected: 1 row inserted.
-- [POSITIVE - Max Boundaries] UnitPrice = 50000.00, QuantityInStock = 100000, ImportDate = TRUNC(SYSDATE)
BEGIN
    SAVEPOINT sp_test;
    INSERT INTO Medication (MedicationID, MedicationName, Manufacturer, Category, DosageForm, UnitPrice, QuantityInStock, ImportDate, ExpirationDate, SupplierID)
    VALUES ('MED_MAX_01', 'Monoclonal Antibody Infusion', 'Roche Diagnostics', 'Cardiovascular', 'Injection', 50000.00, 100000, TRUNC(SYSDATE), TRUNC(SYSDATE) + 730, 'SUP001');
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
/

-- [16] student_4\02_medication\positive\03_defaults_and_nulls
-- Expected: 1 row inserted with QuantityInStock = 0 and ImportDate = SYSDATE.
-- [POSITIVE - Defaults] Omit QuantityInStock (DEFAULT 0) & ImportDate (DEFAULT SYSDATE)
BEGIN
    SAVEPOINT sp_test;
    INSERT INTO Medication (MedicationID, MedicationName, Manufacturer, Category, DosageForm, UnitPrice, ExpirationDate, SupplierID)
    VALUES ('MED_DEF_01', 'Cefuroxime 500mg', 'Pharco Pharma', 'Antibiotic', 'Tablet', 48.00, TRUNC(SYSDATE) + 365, 'SUP001');
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
/

-- [17] student_4\02_medication\positive\04_valid_update
-- Expected: 1 row updated.
-- [POSITIVE - Valid UPDATE] Update UnitPrice & Category
BEGIN
    SAVEPOINT sp_test;
    UPDATE Medication SET UnitPrice = 75.50, Category = 'Antiviral' WHERE MedicationID = 'MED002';
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
/

-- [18] student_4\03_prescription\negative\01_invalid_prescription_id
-- [NEGATIVE] Invalid PrescriptionID (chk_rx_id)
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration)
VALUES ('RX#1', 'PAT001', 'DOC001', 'MED002', '500mg', 'Once daily', 5);
-- Expected: ORA-02290: check constraint (CHK_RX_ID) violated.

-- [19] student_4\03_prescription\negative\02_invalid_patient_fk
-- [NEGATIVE] Non-existent PatientID (fk_rx_patient)
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration)
VALUES ('RX_T2', 'PAT999', 'DOC001', 'MED002', '500mg', 'Once daily', 5);
-- Expected: ORA-02291: integrity constraint (FK_RX_PATIENT) violated.

-- [20] student_4\03_prescription\negative\03_invalid_medication_fk
-- [NEGATIVE] Non-existent MedicationID (fk_rx_medication)
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration)
VALUES ('RX_T3', 'PAT001', 'DOC001', 'MED999', '500mg', 'Once daily', 5);
-- Expected: ORA-02291: integrity constraint (FK_RX_MEDICATION) violated.

-- [21] student_4\03_prescription\negative\04_invalid_frequency
-- [NEGATIVE] Invalid Frequency on UPDATE (chk_rx_frequency)
UPDATE Prescription SET Frequency = 'Hourly' WHERE PrescriptionID = 'RX001';
-- Expected: ORA-02290: check constraint (CHK_RX_FREQUENCY) violated.

-- [22] student_4\03_prescription\negative\05_duration_zero
-- [NEGATIVE] Duration = 0 on UPDATE (chk_rx_duration)
UPDATE Prescription SET Duration = 0 WHERE PrescriptionID = 'RX001';
-- Expected: ORA-02290: check constraint (CHK_RX_DURATION) violated.

-- [23] student_4\03_prescription\negative\06_quantity_zero
-- [NEGATIVE] QuantityPrescribed = 0 on UPDATE (chk_rx_qty)
UPDATE Prescription SET QuantityPrescribed = 0 WHERE PrescriptionID = 'RX001';
-- Expected: ORA-02290: check constraint (CHK_RX_QTY) violated.

-- [24] student_4\03_prescription\negative\07_invalid_dispense_status
-- [NEGATIVE] Invalid DispenseStatus on UPDATE (chk_rx_dispense)
UPDATE Prescription SET DispenseStatus = 'Shipped' WHERE PrescriptionID = 'RX001';
-- Expected: ORA-02290: check constraint (CHK_RX_DISPENSE) violated.

-- [25] student_4\03_prescription\negative\08_notes_too_short
-- [NEGATIVE] Notes < 5 chars on UPDATE (chk_rx_notes_len)
UPDATE Prescription SET Notes = 'Hi' WHERE PrescriptionID = 'RX001';
-- Expected: ORA-02290: check constraint (CHK_RX_NOTES_LEN) violated.

-- [26] student_4\03_prescription\negative\09_date_before_2020
-- [NEGATIVE] PrescriptionDate < 2020-01-01 on UPDATE (chk_rx_date)
UPDATE Prescription SET PrescriptionDate = DATE '2019-05-01' WHERE PrescriptionID = 'RX001';
-- Expected: ORA-02290: check constraint (CHK_RX_DATE) violated.

-- [27] student_4\03_prescription\positive\01_min_boundaries
-- Expected: 1 row inserted.
-- [POSITIVE - Min Boundaries] Duration = 1, QuantityPrescribed = 1, PrescriptionDate = 2020-01-01, 5-char Notes
BEGIN
    SAVEPOINT sp_test;
    INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes)
    VALUES ('R1', 'PAT001', 'DOC001', 'MED002', '500mg', 'Once daily', 1, 1, 'Pending', DATE '2020-01-01', 'Notes');
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
/

-- [28] student_4\03_prescription\positive\02_max_boundaries
-- Expected: 1 row inserted.
-- [POSITIVE - Max Boundaries] Duration = 365, QuantityPrescribed = 500 (Dispensed within MED002 stock), PrescriptionDate = TRUNC(SYSDATE)
BEGIN
    SAVEPOINT sp_test;
    INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, QuantityPrescribed, DispenseStatus, PrescriptionDate, Notes)
    VALUES ('RX_MAX_01', 'PAT002', 'DOC002', 'MED002', '500mg', 'Three times daily', 365, 500, 'Dispensed', TRUNC(SYSDATE), 'Max duration and large quantity test');
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
/

-- [29] student_4\03_prescription\positive\03_defaults_and_nulls
-- Expected: 1 row inserted with defaults applied.
-- [POSITIVE - Defaults & NULLs] Omit QuantityPrescribed (1), DispenseStatus ('Pending'), PrescriptionDate (SYSDATE); Notes = NULL
BEGIN
    SAVEPOINT sp_test;
    INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, Notes)
    VALUES ('RX_DEF_01', 'PAT003', 'DOC003', 'MED002', '500mg', 'Twice daily', 7, NULL);
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
/

-- [30] student_4\03_prescription\positive\04_valid_update
-- Expected: 1 row updated.
-- [POSITIVE - Valid UPDATE] Update Frequency & Notes
BEGIN
    SAVEPOINT sp_test;
    UPDATE Prescription SET Frequency = 'Every 8 hours', Notes = 'Take with water' WHERE PrescriptionID = 'RX001';
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
/

-- [31] student_4\04_laboratory_test\negative\01_invalid_test_id
-- [NEGATIVE] Invalid TestID (chk_lab_id)
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, TestCost)
VALUES ('LAB!1', 'PAT001', 'DOC001', 'Blood Sugar', 100.00);
-- Expected: ORA-02290: check constraint (CHK_LAB_ID) violated.

-- [32] student_4\04_laboratory_test\negative\02_test_type_too_short
-- [NEGATIVE] TestType < 5 chars on UPDATE (chk_lab_type_len)
UPDATE LaboratoryTest SET TestType = 'CBC' WHERE TestID = 'LAB001';
-- Expected: ORA-02290: check constraint (CHK_LAB_TYPE_LEN) violated.

-- [33] student_4\04_laboratory_test\negative\03_negative_cost
-- [NEGATIVE] Negative TestCost on UPDATE (chk_lab_cost)
UPDATE LaboratoryTest SET TestCost = -50 WHERE TestID = 'LAB001';
-- Expected: ORA-02290: check constraint (CHK_LAB_COST) violated.

-- [34] student_4\04_laboratory_test\negative\04_completed_without_result
-- [NEGATIVE] Completed without CompletedDate/TestResult (chk_lab_status_sync)
UPDATE LaboratoryTest SET TestStatus = 'Completed', CompletedDate = NULL, TestResult = NULL WHERE TestID = 'LAB001';
-- Expected: ORA-02290: check constraint (CHK_LAB_STATUS_SYNC) violated.

-- [35] student_4\04_laboratory_test\negative\05_completed_before_requested
-- [NEGATIVE] CompletedDate earlier than RequestedDate (chk_lab_dates)
UPDATE LaboratoryTest SET TestStatus = 'Completed', CompletedDate = DATE '2020-01-01', TestResult = 'Normal result' WHERE TestID = 'LAB001';
-- Expected: ORA-02290: check constraint (CHK_LAB_DATES) violated.

-- [36] student_4\04_laboratory_test\negative\06_result_too_short
-- [NEGATIVE] TestResult < 5 chars (chk_lab_result_len)
UPDATE LaboratoryTest SET TestStatus = 'Completed', CompletedDate = TRUNC(SYSDATE), TestResult = 'Ok' WHERE TestID = 'LAB001';
-- Expected: ORA-02290: check constraint (CHK_LAB_RESULT_LEN) violated.

-- [37] student_4\04_laboratory_test\negative\07_invalid_test_status
-- [NEGATIVE] Invalid TestStatus (chk_lab_status / chk_lab_status_sync)
UPDATE LaboratoryTest SET TestStatus = 'Archived' WHERE TestID = 'LAB001';
-- Expected: ORA-02290: check constraint (CHK_LAB_STATUS / CHK_LAB_STATUS_SYNC) violated.
-- Note: Oracle does not guarantee evaluation order between two overlapping CHECK constraints.

-- [38] student_4\04_laboratory_test\positive\01_min_boundaries
-- Expected: 1 row inserted.
-- [POSITIVE - Min Boundaries] RequestedDate = 2020-01-01, TestCost = 0.01, 5-char TestType
BEGIN
    SAVEPOINT sp_test;
    INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, TestStatus, TestCost)
    VALUES ('L1', 'PAT001', 'DOC001', 'Urine', DATE '2020-01-01', 'Pending', 0.01);
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
/

-- [39] student_4\04_laboratory_test\positive\02_max_boundaries
-- Expected: 1 row inserted.
-- [POSITIVE - Max Boundaries] TestCost = 50000.00, Completed with CompletedDate & TestResult
BEGIN
    SAVEPOINT sp_test;
    INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost)
    VALUES ('LAB_MAX_01', 'PAT002', 'DOC002', 'Whole Genome Sequencing Panel', TRUNC(SYSDATE), TRUNC(SYSDATE), 'Completed', 'No pathogenic variants detected', 50000.00);
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
/

-- [40] student_4\04_laboratory_test\positive\03_defaults_and_nulls
-- Expected: 1 row inserted with TestStatus = 'Pending' and RequestedDate = SYSDATE.
-- [POSITIVE - Defaults & NULLs] Omit RequestedDate (SYSDATE), TestStatus ('Pending'); CompletedDate & TestResult = NULL
BEGIN
    SAVEPOINT sp_test;
    INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, CompletedDate, TestResult, TestCost)
    VALUES ('LAB_DEF_01', 'PAT003', 'DOC003', 'Lipid Profile Panel', NULL, NULL, 320.00);
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
/

-- [41] student_4\04_laboratory_test\positive\04_valid_update
-- Expected: 1 row updated.
-- [POSITIVE - Valid UPDATE] Complete a Pending Lab Test with CompletedDate & TestResult
BEGIN
    SAVEPOINT sp_test;
    UPDATE LaboratoryTest SET TestStatus = 'Completed', CompletedDate = TRUNC(SYSDATE), TestResult = 'Normal blood count' WHERE TestID = 'LAB001';
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
/
