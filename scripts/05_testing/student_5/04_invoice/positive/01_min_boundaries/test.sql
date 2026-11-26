-- [POSITIVE - Min Boundaries] TotalAmount = 0.01, Discount = 0.00, InvoiceDate = 2020-01-01, DueDate = InvoiceDate
BEGIN
    SAVEPOINT sp_test;
    INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus)
    VALUES ('V1', 'PAT001', DATE '2020-01-01', 0.01, 0.00, DATE '2020-01-01', 'Overdue');
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
-- Expected: 1 row inserted.
