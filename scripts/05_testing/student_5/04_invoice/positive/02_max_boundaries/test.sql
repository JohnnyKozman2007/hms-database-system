-- [POSITIVE - Max Boundaries] Discount = TotalAmount (100% discount), DueDate = InvoiceDate + 3
BEGIN
    SAVEPOINT sp_test;
    INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus)
    VALUES ('INV_MAX_01', 'PAT002', TRUNC(SYSDATE), 50000.00, 50000.00, TRUNC(SYSDATE) + 3, 'Unpaid');
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
-- Expected: 1 row inserted.
