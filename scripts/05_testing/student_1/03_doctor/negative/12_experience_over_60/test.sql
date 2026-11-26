-- [NEGATIVE] YearsOfExperience > 60 (chk_doc_exp)
UPDATE Doctor SET YearsOfExperience = 61 WHERE DoctorID = 'DOC001';
-- Expected: ORA-02290: check constraint (CHK_DOC_EXP) violated.
