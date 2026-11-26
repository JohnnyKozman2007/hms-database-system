-- [NEGATIVE - Mohamed] Invalid Building (chk_room_bldg)
INSERT INTO Room (RoomID, RoomNumber, Building, Floor, RoomType, Capacity, DailyCharge)
VALUES ('RM995', '995', 'Building E', 'Ground Floor', 'Private', 1, 1800.00);
-- Expected / Actual (Screenshot): ORA-02290: check constraint (CHK_ROOM_BLDG) violated.
