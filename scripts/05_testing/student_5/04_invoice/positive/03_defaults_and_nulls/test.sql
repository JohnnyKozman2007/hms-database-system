-- [POSITIVE - Defaults] Omit InvoiceDate (SYSDATE), Discount (0.00), DueDate (SYSDATE + 3), PaymentStatus ('Unpaid')
BEGIN
    SAVEPOINT sp_test;
    INSERT INTO Invoice (InvoiceID, PatientID, TotalAmount)
    VALUES ('INV_DEF_01', 'PAT003', 1500.00);
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
-- Expected: 1 row inserted with defaults applied.
