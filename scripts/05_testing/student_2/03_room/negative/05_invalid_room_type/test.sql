-- [NEGATIVE - Mohamed] Invalid RoomType (chk_room_type_cap / chk_room_type)
INSERT INTO Room (RoomID, RoomNumber, Building, Floor, RoomType, Capacity, DailyCharge)
VALUES ('RM999', '999', 'Building A', 'Ground Floor', 'VIP Suite', 1, 3000.00);
-- Expected / Actual (Screenshot): ORA-02290: check constraint (CHK_ROOM_TYPE_CAP) violated.
