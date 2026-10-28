-- ============================================================================
-- SEED DATA: Room (Student 2)
-- Target: Minimum 50 rooms
-- ID Range: 1 to 50
-- ============================================================================

INSERT INTO Room (RoomID, RoomNumber, Floor, RoomType, Capacity, DailyCharge, AvailabilityStatus)
VALUES (1, 'R-101', 1, 'General Ward', 4, 150.00, 'Available');

INSERT INTO Room (RoomID, RoomNumber, Floor, RoomType, Capacity, DailyCharge, AvailabilityStatus)
VALUES (2, 'R-102', 1, 'Private', 1, 350.00, 'Occupied');

INSERT INTO Room (RoomID, RoomNumber, Floor, RoomType, Capacity, DailyCharge, AvailabilityStatus)
VALUES (3, 'R-201', 2, 'ICU', 2, 750.00, 'Available');

-- Add remaining rooms (4 to 50) following this exact pattern.
COMMIT;
