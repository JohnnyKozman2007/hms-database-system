-- [NEGATIVE] Duplicate Email on UPDATE (uq_pat_email)
UPDATE Patient SET Email = 'fatma.zaki.002@mail.eg' WHERE PatientID = 'PAT001';
-- Expected: ORA-00001: unique constraint (UQ_PAT_EMAIL) violated.
