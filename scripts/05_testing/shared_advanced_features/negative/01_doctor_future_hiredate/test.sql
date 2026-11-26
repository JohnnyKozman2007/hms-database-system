-- [NEGATIVE] Future Doctor.HireDate (trg_doc_date_max)
UPDATE Doctor SET HireDate = SYSDATE + 5 WHERE DoctorID = 'DOC001';
-- Expected: ORA-20001: Doctor.HireDate cannot be in the future (exceeds SYSDATE).
