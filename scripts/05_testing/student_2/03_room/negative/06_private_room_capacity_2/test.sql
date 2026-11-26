-- [NEGATIVE - Mohamed] Private room with Capacity = 2 (chk_room_type_cap)
INSERT INTO Room (RoomID, RoomNumber, Building, Floor, RoomType, Capacity, DailyCharge)
VALUES ('RM998', '998', 'Building A', '1st Floor', 'Private', 2, 2000.00);
-- Expected / Actual (Screenshot): ORA-02290: check constraint (CHK_ROOM_TYPE_CAP) violated.
