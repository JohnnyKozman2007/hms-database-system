-- [NEGATIVE] Invalid RoomID (chk_room_id)
INSERT INTO Room (RoomID, RoomNumber, Building, Floor, RoomType, DailyCharge)
VALUES ('RM@1', '992', 'Building A', '1st Floor', 'Private', 1000.00);
-- Expected: ORA-02290: check constraint (CHK_ROOM_ID) violated.
