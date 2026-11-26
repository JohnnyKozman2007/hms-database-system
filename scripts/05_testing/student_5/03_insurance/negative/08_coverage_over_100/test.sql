-- [NEGATIVE] CoveragePercentage > 100 (chk_ins_cov)
UPDATE Insurance SET CoveragePercentage = 105 WHERE InsuranceID = 'INS001';
-- Expected: ORA-02290: check constraint (CHK_INS_COV) violated.
