-- [NEGATIVE] Invalid Email format on UPDATE (chk_doc_email_fmt)
UPDATE Doctor SET Email = 'invalid_email' WHERE DoctorID = 'DOC001';
-- Expected: ORA-02290: check constraint (CHK_DOC_EMAIL_FMT) violated.
