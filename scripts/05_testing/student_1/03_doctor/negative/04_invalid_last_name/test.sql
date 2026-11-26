-- [NEGATIVE] Symbols in LastName on UPDATE (chk_doc_lname)
UPDATE Doctor SET LastName = 'Ali@99' WHERE DoctorID = 'DOC001';
-- Expected: ORA-02290: check constraint (CHK_DOC_LNAME) violated.
