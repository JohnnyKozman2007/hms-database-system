-- [NEGATIVE - Mohamed] Exceed room capacity (RM002 is already full with 2 patients)
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionReason)
VALUES ('ADM992', 'PAT020', 'RM002', 'This should exceed the room capacity');
-- Expected / Actual (Screenshot): ORA-20010: Room capacity exceeded for Room RM002 (Capacity: 2).
