-- [POSITIVE - Defaults & NULLs] Omit RecordDate (SYSDATE); Notes = NULL, FollowUpDate = NULL
BEGIN
    SAVEPOINT sp_test;
    INSERT INTO MedicalRecord (RecordID, PatientID, DoctorID, Diagnosis, Treatment, Notes, FollowUpDate)
    VALUES ('MR_DEF_01', 'PAT003', 'DOC003', 'Seasonal Allergic Rhinitis', 'Antihistamine nasal spray', NULL, NULL);
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
-- Expected: 1 row inserted with RecordDate = SYSDATE.
