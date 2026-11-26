-- [NEGATIVE] Duplicate RoomID (pk_room)
INSERT INTO Room (RoomID, RoomNumber, Building, Floor, RoomType, DailyCharge)
VALUES ('RM001', '991', 'Building A', '1st Floor', 'Private', 1000.00);
-- Expected: ORA-00001: unique constraint (PK_ROOM) violated.
