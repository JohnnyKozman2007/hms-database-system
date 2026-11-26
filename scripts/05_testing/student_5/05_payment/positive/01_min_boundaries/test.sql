-- [POSITIVE - Min Boundaries] AmountPaid = 0.01, PaymentDate = TRUNC(SYSDATE), 4-char TransactionReference
BEGIN
    SAVEPOINT sp_test;
    INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus)
    VALUES ('INV_PT1', 'PAT001', TRUNC(SYSDATE), 1000.00, 0.00, TRUNC(SYSDATE) + 3, 'Unpaid');
    INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus)
    VALUES ('Y1', 'INV_PT1', TRUNC(SYSDATE), 0.01, 'Cash', 'TX01', 'Completed');
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
-- Expected: 1 row inserted.
