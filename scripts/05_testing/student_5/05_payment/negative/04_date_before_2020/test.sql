-- [NEGATIVE] PaymentDate < 2020-01-01 (chk_pay_date_lower; non-existent INV999 lets trigger defer to CHECK)
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference)
VALUES ('PAY_DT1', 'INV999', DATE '2019-12-31', 100.00, 'Cash', 'TXN-DT-01');
-- Expected: ORA-02290: check constraint (CHK_PAY_DATE_LOWER) violated.
