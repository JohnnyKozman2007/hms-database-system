-- [NEGATIVE] PolicyNumber < 4 chars or invalid chars (chk_ins_policy_fmt)
UPDATE Insurance SET PolicyNumber = 'P1' WHERE InsuranceID = 'INS001';
-- Expected: ORA-02290: check constraint (CHK_INS_POLICY_FMT) violated.
