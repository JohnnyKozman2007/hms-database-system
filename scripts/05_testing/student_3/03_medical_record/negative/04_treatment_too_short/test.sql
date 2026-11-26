-- [NEGATIVE] Treatment < 5 chars on UPDATE (chk_mr_treat_len)
UPDATE MedicalRecord SET Treatment = 'Rest' WHERE RecordID = 'MR001';
-- Expected: ORA-02290: check constraint (CHK_MR_TREAT_LEN) violated.
