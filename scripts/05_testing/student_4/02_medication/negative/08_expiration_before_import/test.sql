-- [NEGATIVE] ExpirationDate <= ImportDate on UPDATE (chk_med_dates)
UPDATE Medication SET ExpirationDate = DATE '2020-01-01' WHERE MedicationID = 'MED002';
-- Expected: ORA-02290: check constraint (CHK_MED_DATES) violated.
