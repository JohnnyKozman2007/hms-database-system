-- [NEGATIVE] ExpirationDate <= StartDate (chk_ins_dates; Cancelled bypasses trg_ins_status_date_guard)
UPDATE Insurance SET InsuranceStatus = 'Cancelled', ExpirationDate = StartDate WHERE InsuranceID = 'INS001';
-- Expected: ORA-02290: check constraint (CHK_INS_DATES) violated.
