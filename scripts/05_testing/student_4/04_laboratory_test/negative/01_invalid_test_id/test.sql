-- [NEGATIVE] Invalid TestID (chk_lab_id)
INSERT INTO LaboratoryTest (TestID, PatientID, DoctorID, TestType, TestCost)
VALUES ('LAB!1', 'PAT001', 'DOC001', 'Blood Sugar', 100.00);
-- Expected: ORA-02290: check constraint (CHK_LAB_ID) violated.
