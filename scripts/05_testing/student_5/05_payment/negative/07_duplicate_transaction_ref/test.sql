-- [NEGATIVE] Duplicate TransactionReference (uq_pay_ref)
INSERT INTO Payment (PaymentID, InvoiceID, AmountPaid, PaymentMethod, TransactionReference)
VALUES ('PAY_REF1', 'INV001', 100.00, 'Cash', (SELECT TransactionReference FROM Payment WHERE PaymentID = 'PAY001'));
-- Expected: ORA-00001: unique constraint (UQ_PAY_REF) violated.
