-- [NEGATIVE] Invalid MedicationID (chk_med_id)
INSERT INTO Medication (MedicationID, MedicationName, Manufacturer, Category, DosageForm, UnitPrice, QuantityInStock, ImportDate, ExpirationDate, SupplierID)
VALUES ('MED@1', 'Valid Name', 'Valid Mfg', 'Antibiotic', 'Tablet', 10.00, 10, DATE '2025-06-01', DATE '2028-06-01', 'SUP001');
-- Expected: ORA-02290: check constraint (CHK_MED_ID) violated.
