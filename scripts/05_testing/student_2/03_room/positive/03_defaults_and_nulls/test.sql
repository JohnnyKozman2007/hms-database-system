-- [POSITIVE - Defaults] Omit Capacity (DEFAULT 1) & AvailabilityStatus (DEFAULT 'Available')
BEGIN
    SAVEPOINT sp_test;
    INSERT INTO Room (RoomID, RoomNumber, Building, Floor, RoomType, DailyCharge)
    VALUES ('RM_DEF_01', '299', 'Building B', '2nd Floor', 'ICU', 3500.00);
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
-- Expected: 1 row inserted with Capacity = 1 and AvailabilityStatus = 'Available'.
