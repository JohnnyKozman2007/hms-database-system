-- [NEGATIVE] Future MedicalRecord.RecordDate (trg_mr_date_max)
UPDATE MedicalRecord SET RecordDate = SYSDATE + 1 WHERE RecordID = 'MR001';
-- Expected: ORA-20001: MedicalRecord.RecordDate cannot be in the future (exceeds SYSDATE).
