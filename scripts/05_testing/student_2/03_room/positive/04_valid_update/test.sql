-- [POSITIVE - Valid UPDATE] Update DailyCharge & AvailabilityStatus
BEGIN
    SAVEPOINT sp_test;
    UPDATE Room SET DailyCharge = 3750.00, AvailabilityStatus = 'Maintenance' WHERE RoomID = 'RM029';
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
-- Expected: 1 row updated.
