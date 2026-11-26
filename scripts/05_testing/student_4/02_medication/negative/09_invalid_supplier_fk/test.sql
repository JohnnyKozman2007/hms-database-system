-- [NEGATIVE] Non-existent SupplierID on UPDATE (fk_med_supplier)
UPDATE Medication SET SupplierID = 'SUP999' WHERE MedicationID = 'MED002';
-- Expected: ORA-02291: integrity constraint (FK_MED_SUPPLIER) violated.
