-- [NEGATIVE] Future Insurance.StartDate (trg_ins_start_date_max)
UPDATE Insurance SET StartDate = SYSDATE + 1 WHERE InsuranceID = 'INS001';
-- Expected: ORA-20001: Insurance.StartDate cannot be in the future (exceeds SYSDATE).
