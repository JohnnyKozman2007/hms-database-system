-- [NEGATIVE] NULL Specialty on UPDATE
UPDATE Doctor SET Specialty = NULL WHERE DoctorID = 'DOC001';
-- Expected: ORA-01407: cannot update (DOCTOR.SPECIALTY) to NULL.
