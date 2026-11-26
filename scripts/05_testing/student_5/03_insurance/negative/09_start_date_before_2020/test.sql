-- [NEGATIVE] StartDate < 2020-01-01 (chk_ins_start_date)
UPDATE Insurance SET StartDate = DATE '2019-12-31' WHERE InsuranceID = 'INS001';
-- Expected: ORA-02290: check constraint (CHK_INS_START_DATE) violated.
