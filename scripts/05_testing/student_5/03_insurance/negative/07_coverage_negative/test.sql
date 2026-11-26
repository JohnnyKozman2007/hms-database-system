-- [NEGATIVE] CoveragePercentage < 0 (chk_ins_cov)
UPDATE Insurance SET CoveragePercentage = -5 WHERE InsuranceID = 'INS001';
-- Expected: ORA-02290: check constraint (CHK_INS_COV) violated.
