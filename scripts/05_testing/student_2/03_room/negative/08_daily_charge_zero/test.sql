-- [NEGATIVE - Mohamed] DailyCharge = 0 (chk_room_charge)
INSERT INTO Room (RoomID, RoomNumber, Building, Floor, RoomType, Capacity, DailyCharge)
VALUES ('RM996', '996', 'Building C', '3rd Floor', 'ICU', 1, 0);
-- Expected / Actual (Screenshot): ORA-02290: check constraint (CHK_ROOM_CHARGE) violated.
