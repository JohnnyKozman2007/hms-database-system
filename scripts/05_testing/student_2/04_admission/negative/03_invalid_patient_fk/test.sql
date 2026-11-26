-- [NEGATIVE] Non-existent PatientID (fk_adm_patient)
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionReason)
VALUES ('ADM_FK1', 'PAT999', 'RM029', 'Invalid patient FK test');
-- Expected: ORA-02291: integrity constraint (FK_ADM_PATIENT) violated.
