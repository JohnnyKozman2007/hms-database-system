-- [NEGATIVE] Duplicate Phone on UPDATE (uq_pat_phone)
UPDATE Patient SET Phone = '01155550002' WHERE PatientID = 'PAT001';
-- Expected: ORA-00001: unique constraint (UQ_PAT_PHONE) violated.
