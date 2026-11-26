-- [NEGATIVE] UnitPrice <= 0 on UPDATE (chk_med_unit_price)
UPDATE Medication SET UnitPrice = 0 WHERE MedicationID = 'MED002';
-- Expected: ORA-02290: check constraint (CHK_MED_UNIT_PRICE) violated.
