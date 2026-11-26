-- [POSITIVE - Defaults] Omit PaymentDate (SYSDATE) & PaymentStatus ('Completed')
BEGIN
    SAVEPOINT sp_test;
    INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus)
    VALUES ('INV_PT3', 'PAT001', TRUNC(SYSDATE), 2000.00, 0.00, TRUNC(SYSDATE) + 3, 'Unpaid');
    INSERT INTO Payment (PaymentID, InvoiceID, AmountPaid, PaymentMethod, TransactionReference)
    VALUES ('PAY_DEF_01', 'INV_PT3', 500.00, 'Debit Card', 'TXN-DEF-001');
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
-- Expected: 1 row inserted with defaults applied.
