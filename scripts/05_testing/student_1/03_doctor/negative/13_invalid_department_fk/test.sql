-- [NEGATIVE] Non-existent DepartmentID (fk_doc_dept)
UPDATE Doctor SET DepartmentID = 'DEPT999' WHERE DoctorID = 'DOC001';
-- Expected: ORA-02291: integrity constraint (FK_DOC_DEPT) violated.
