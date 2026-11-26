-- [NEGATIVE] Invalid AdmissionID (chk_adm_id)
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionReason)
VALUES ('ADM@1', 'PAT020', 'RM029', 'Invalid ID test');
-- Expected: ORA-02290: check constraint (CHK_ADM_ID) violated.
