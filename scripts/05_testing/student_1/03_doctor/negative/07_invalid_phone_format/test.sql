-- [NEGATIVE] Invalid Mobile Phone length on UPDATE (chk_doc_phone)
UPDATE Doctor SET PhoneType = 'Mobile', Phone = '010123' WHERE DoctorID = 'DOC001';
-- Expected: ORA-02290: check constraint (CHK_DOC_PHONE) violated.
