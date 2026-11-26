-- [NEGATIVE - Mohamed] Capacity = 0 (chk_room_capacity)
INSERT INTO Room (RoomID, RoomNumber, Building, Floor, RoomType, Capacity, DailyCharge)
VALUES ('RM997', '997', 'Building B', '2nd Floor', 'General Ward', 0, 500.00);
-- Expected / Actual (Screenshot): ORA-02290: check constraint (CHK_ROOM_CAPACITY) violated.
