-- [NEGATIVE] Self-supervision (chk_doc_no_self_sup)
UPDATE Doctor SET SupervisorID = 'DOC001' WHERE DoctorID = 'DOC001';
-- Expected: ORA-02290: check constraint (CHK_DOC_NO_SELF_SUP) violated.
