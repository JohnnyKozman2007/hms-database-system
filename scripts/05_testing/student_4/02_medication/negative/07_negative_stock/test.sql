-- [NEGATIVE] Negative QuantityInStock on UPDATE (chk_med_stock)
UPDATE Medication SET QuantityInStock = -5 WHERE MedicationID = 'MED002';
-- Expected: ORA-02290: check constraint (CHK_MED_STOCK) violated.
