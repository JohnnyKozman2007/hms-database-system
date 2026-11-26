-- [NEGATIVE - Mohamed] Second active admission for same patient (uq_adm_one_active_stay)
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionReason)
VALUES ('ADM994', 'PAT001', 'RM010', 'Second active stay should be rejected');
-- Expected / Actual (Screenshot): ORA-00001: unique constraint (UQ_ADM_ONE_ACTIVE_STAY) violated.
