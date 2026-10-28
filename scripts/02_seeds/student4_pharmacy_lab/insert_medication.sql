-- ============================================================================
-- SEED DATA: Medication (Student 4)
-- Target: Minimum 50 medications
-- ID Range: 1 to 50
-- Foreign Keys: SupplierID (1..15 from Student 5)
-- ============================================================================

INSERT INTO Medication (MedicationID, MedicationName, Manufacturer, Category, DosageForm, UnitPrice, QuantityInStock, ExpirationDate, SupplierID)
VALUES (1, 'Amoxicillin 500mg', 'GlaxoSmithKline', 'Antibiotic', 'Capsule', 12.50, 450, DATE '2027-12-31', 1);

INSERT INTO Medication (MedicationID, MedicationName, Manufacturer, Category, DosageForm, UnitPrice, QuantityInStock, ExpirationDate, SupplierID)
VALUES (2, 'Lisinopril 10mg', 'AstraZeneca', 'Antihypertensive', 'Tablet', 8.20, 600, DATE '2028-06-30', 2);

-- Add remaining medications (3 to 50) following this exact pattern.
COMMIT;
