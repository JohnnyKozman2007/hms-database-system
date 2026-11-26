-- [NEGATIVE - Mohamed] Admit into a Maintenance room (RM041)
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionReason)
VALUES ('ADM993', 'PAT020', 'RM041', 'Should be blocked by the trigger');
-- Expected / Actual (Screenshot): ORA-20011: Cannot admit patient to Room RM041: Room is currently under Maintenance.
