-- [POSITIVE - Valid UPDATE] Update PaymentMethod & PaymentStatus
BEGIN
    SAVEPOINT sp_test;
    UPDATE Payment SET PaymentMethod = 'Credit Card', PaymentStatus = 'Refunded' WHERE PaymentID = 'PAY001';
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
-- Expected: 1 row updated.
