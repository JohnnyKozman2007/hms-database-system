-- [NEGATIVE] Invalid InsuranceStatus (chk_ins_status)
UPDATE Insurance SET InsuranceStatus = 'Pending' WHERE InsuranceID = 'INS001';
-- Expected: ORA-02290: check constraint (CHK_INS_STATUS) violated.
