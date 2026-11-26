-- [NEGATIVE] Duplicate Phone on UPDATE (uq_doc_phone)
UPDATE Doctor SET PhoneType = 'Mobile', Phone = '01012340002' WHERE DoctorID = 'DOC001';
-- Expected: ORA-00001: unique constraint (UQ_DOC_PHONE) violated.
