-- [NEGATIVE] Duplicate Email on UPDATE (uq_doc_email)
UPDATE Doctor SET Email = 'ahmed.elsayed@hms.org' WHERE DoctorID = 'DOC001';
-- Expected: ORA-00001: unique constraint (UQ_DOC_EMAIL) violated.
