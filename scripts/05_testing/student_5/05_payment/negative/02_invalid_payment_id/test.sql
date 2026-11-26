-- [NEGATIVE] Invalid PaymentID format (chk_pay_id)
INSERT INTO Payment (PaymentID, InvoiceID, AmountPaid, PaymentMethod, TransactionReference)
VALUES ('PAY@1', 'INV001', 100.00, 'Cash', 'TXN-BAD-ID-01');
-- Expected: ORA-02290: check constraint (CHK_PAY_ID) violated.
