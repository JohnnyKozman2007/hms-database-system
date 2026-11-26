-- [NEGATIVE] Invalid Gender on UPDATE (chk_doc_gender)
UPDATE Doctor SET Gender = 'Unknown' WHERE DoctorID = 'DOC001';
-- Expected: ORA-02290: check constraint (CHK_DOC_GENDER) violated.
