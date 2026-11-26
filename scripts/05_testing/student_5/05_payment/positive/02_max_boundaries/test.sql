-- [POSITIVE - Max Boundaries] PaymentDate = TRUNC(SYSDATE), Bank Transfer
BEGIN
    SAVEPOINT sp_test;
    INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus)
    VALUES ('INV_PT2', 'PAT001', TRUNC(SYSDATE), 2000.00, 0.00, TRUNC(SYSDATE) + 3, 'Unpaid');
    INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus)
    VALUES ('PAY_MAX_01', 'INV_PT2', TRUNC(SYSDATE), 1000.00, 'Bank Transfer', 'TXN-MAX-BOUNDARY-2026-001', 'Completed');
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
-- Expected: 1 row inserted.
