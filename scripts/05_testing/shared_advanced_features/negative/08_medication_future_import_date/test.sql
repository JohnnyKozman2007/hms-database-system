-- [NEGATIVE] Future Medication.ImportDate (trg_med_import_date_max)
UPDATE Medication SET ImportDate = SYSDATE + 1 WHERE MedicationID = 'MED002';
-- Expected: ORA-20001: Medication.ImportDate cannot be in the future (exceeds SYSDATE).
