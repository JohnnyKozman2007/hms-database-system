-- ============================================================================
-- TESTING SUITE: Student 4 (Medication, Prescription, LaboratoryTest)
-- ============================================================================

-- POSITIVE TEST 1: Insert valid Medication
INSERT INTO Medication (MedicationID, MedicationName, Manufacturer, Category, DosageForm, UnitPrice, QuantityInStock, ExpirationDate, SupplierID)
VALUES (999, 'TestDrug 10mg', 'TestLab', 'Analgesic', 'Tablet', 5.50, 100, DATE '2028-01-01', 1);
-- Expected: 1 row inserted.

-- NEGATIVE TEST 1: Attempt medication with negative QuantityInStock (CHECK constraint violation)
-- Expected Oracle Error: ORA-02290 (check constraint violated)
INSERT INTO Medication (MedicationID, MedicationName, Manufacturer, Category, DosageForm, UnitPrice, QuantityInStock, ExpirationDate, SupplierID)
VALUES (998, 'NegativeStock Drug', 'TestLab', 'Analgesic', 'Tablet', 5.50, -20, DATE '2028-01-01', 1);

-- NEGATIVE TEST 2: Attempt prescription with nonexistent MedicationID (FK constraint violation)
-- Expected Oracle Error: ORA-02291 (parent key not found)
INSERT INTO Prescription (PrescriptionID, PatientID, DoctorID, MedicationID, Dosage, Frequency, Duration, PrescriptionDate, Notes)
VALUES (9999, 1, 1, 99999, '10mg', 'Daily', '7 days', SYSDATE, 'Invalid Med Test');

-- NEGATIVE TEST 3: Attempt LaboratoryTest where CompletedDate is before RequestedDate
-- Expected Oracle Error: ORA-02290 (check constraint violated)
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, RequestedDate, CompletedDate, TestStatus, TestResult, TestCost)
VALUES (9999, 1, 1, 'Blood Test', DATE '2026-05-10', DATE '2026-05-01', 'Completed', 'Normal', 50.00);
ROLLBACK;
