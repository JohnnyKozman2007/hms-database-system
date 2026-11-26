-- [NEGATIVE] Invalid InsuranceCompany (chk_ins_company)
UPDATE Insurance SET InsuranceCompany = 'Unknown Insurance' WHERE InsuranceID = 'INS001';
-- Expected: ORA-02290: check constraint (CHK_INS_COMPANY) violated.
