-- [POSITIVE - Valid UPDATE] Update TotalAmount & Discount
BEGIN
    SAVEPOINT sp_test;
    UPDATE Invoice SET TotalAmount = 2000.00, Discount = 100.00 WHERE InvoiceID = 'INV001';
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
-- Expected: 1 row updated.
