-- [POSITIVE - Max Boundaries] Capacity = 20 (General Ward), DailyCharge = 10000.00
BEGIN
    SAVEPOINT sp_test;
    INSERT INTO Room (RoomID, RoomNumber, Building, Floor, RoomType, Capacity, DailyCharge, AvailabilityStatus)
    VALUES ('RM_MAX_01', '599-A', 'Building D', '5th Floor', 'General Ward', 20, 10000.00, 'Reserved');
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
-- Expected: 1 row inserted.
