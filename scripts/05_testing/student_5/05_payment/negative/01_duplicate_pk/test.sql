-- [NEGATIVE] Duplicate PaymentID (pk_payment)
INSERT INTO Payment (PaymentID, InvoiceID, AmountPaid, PaymentMethod, TransactionReference)
VALUES ('PAY001', 'INV001', 100.00, 'Cash', 'TXN-DUP-PK-01');
-- Expected: ORA-00001: unique constraint (PK_PAYMENT) violated.
