-- [NEGATIVE] HireDate before 1980-01-01 (chk_doc_hire_date)
UPDATE Doctor SET HireDate = DATE '1970-01-01' WHERE DoctorID = 'DOC001';
-- Expected: ORA-02290: check constraint (CHK_DOC_HIRE_DATE) violated.
