-- [NEGATIVE] Non-existent InvoiceID (fk_pay_invoice)
INSERT INTO Payment (PaymentID, InvoiceID, AmountPaid, PaymentMethod, TransactionReference)
VALUES ('PAY_FK1', 'INV999', 100.00, 'Cash', 'TXN-FK-01');
-- Expected: ORA-02291: integrity constraint (FK_PAY_INVOICE) violated.
