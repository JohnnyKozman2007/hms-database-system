-- [NEGATIVE - Mohamed] Invalid RoomType (chk_room_type / chk_room_type_cap)
INSERT INTO Room (RoomID, RoomNumber, Building, Floor, RoomType, Capacity, DailyCharge)
VALUES ('RM999', '999', 'Building A', 'Ground Floor', 'VIP Suite', 1, 3000.00);
-- Expected / Actual (Screenshot): ORA-02290: check constraint (CHK_ROOM_TYPE / CHK_ROOM_TYPE_CAP) violated.
-- Note: Oracle does not guarantee evaluation order between two overlapping CHECK constraints.
