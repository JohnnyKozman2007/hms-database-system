-- [NEGATIVE] trg_pay_balance_and_status: PaymentDate earlier than InvoiceDate
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus)
VALUES ('PAY_NEG2', 'INV001', DATE '2020-01-01', 100.00, 'Cash', 'TXN-NEG-DT-01', 'Completed');
-- Expected: ORA-20004: PaymentDate cannot be earlier than Invoice.InvoiceDate for Invoice INV001.
