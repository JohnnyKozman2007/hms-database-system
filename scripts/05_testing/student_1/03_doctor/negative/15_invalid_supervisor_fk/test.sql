-- [NEGATIVE] Non-existent SupervisorID (fk_doc_supervisor)
UPDATE Doctor SET SupervisorID = 'DOC999' WHERE DoctorID = 'DOC001';
-- Expected: ORA-02291: integrity constraint (FK_DOC_SUPERVISOR) violated.
