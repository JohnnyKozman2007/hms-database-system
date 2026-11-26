-- [NEGATIVE] Invalid Gender on UPDATE (chk_pat_gender)
UPDATE Patient SET Gender = 'Other' WHERE PatientID = 'PAT001';
-- Expected: ORA-02290: check constraint (CHK_PAT_GENDER) violated.
