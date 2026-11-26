-- [POSITIVE - Min Boundaries] Capacity = 1, DailyCharge = 0.01
BEGIN
    SAVEPOINT sp_test;
    INSERT INTO Room (RoomID, RoomNumber, Building, Floor, RoomType, Capacity, DailyCharge, AvailabilityStatus)
    VALUES ('R1', '1', 'Building A', 'Ground Floor', 'Private', 1, 0.01, 'Available');
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
-- Expected: 1 row inserted.
