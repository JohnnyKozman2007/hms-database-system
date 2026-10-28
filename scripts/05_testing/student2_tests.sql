-- ============================================================================
-- TESTING SUITE: Student 2 (Patient, Room, Admission)
-- ============================================================================

-- POSITIVE TEST 1: Insert valid Room
INSERT INTO Room (RoomID, RoomNumber, Floor, RoomType, Capacity, DailyCharge, AvailabilityStatus)
VALUES (999, 'R-999', 3, 'Private', 1, 300.00, 'Available');
-- Expected: 1 row inserted.

-- NEGATIVE TEST 1: Attempt room with 0 or negative capacity (CHECK constraint violation)
-- Expected Oracle Error: ORA-02290 (check constraint violated)
INSERT INTO Room (RoomID, RoomNumber, Floor, RoomType, Capacity, DailyCharge, AvailabilityStatus)
VALUES (998, 'R-998', 1, 'Private', 0, 300.00, 'Available');

-- NEGATIVE TEST 2: Attempt admission with invalid RoomID (FK constraint violation)
-- Expected Oracle Error: ORA-02291 (integrity constraint violated - parent key not found)
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus)
VALUES (9999, 1, 9999, SYSDATE, NULL, 'Test Invalid Room', 'Admitted');

-- NEGATIVE TEST 3: Attempt admission where DischargeDate is before AdmissionDate
-- Expected Oracle Error: ORA-02290 (check constraint violated)
INSERT INTO Admission (AdmissionID, PatientID, RoomID, AdmissionDate, DischargeDate, AdmissionReason, AdmissionStatus)
VALUES (9998, 1, 1, DATE '2026-03-10', DATE '2026-03-01', 'Test Bad Dates', 'Discharged');
ROLLBACK;
