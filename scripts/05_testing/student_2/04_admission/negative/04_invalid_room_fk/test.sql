-- [NEGATIVE] Non-existent RoomID (fk_adm_room)
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionReason)
VALUES ('ADM_FK2', 'PAT020', 'RM999', 'Invalid room FK test');
-- Expected: ORA-02291: integrity constraint (FK_ADM_ROOM) violated.
