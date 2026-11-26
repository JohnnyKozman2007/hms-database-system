-- [NEGATIVE - Mohamed] Invalid Floor (chk_room_floor)
INSERT INTO Room (RoomID, RoomNumber, Building, Floor, RoomType, Capacity, DailyCharge)
VALUES ('RM994', '994', 'Building A', '6th Floor', 'Private', 1, 1800.00);
-- Expected / Actual (Screenshot): ORA-02290: check constraint (CHK_ROOM_FLOOR) violated.
