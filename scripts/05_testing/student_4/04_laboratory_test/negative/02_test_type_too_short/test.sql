-- [NEGATIVE] TestType < 5 chars on UPDATE (chk_lab_type_len)
UPDATE LaboratoryTest SET TestType = 'CBC' WHERE TestID = 'LAB001';
-- Expected: ORA-02290: check constraint (CHK_LAB_TYPE_LEN) violated.
