-- [NEGATIVE] trg_inv_status_guard: Manually set INV001 PaymentStatus to Paid with 0 payments
UPDATE Invoice SET PaymentStatus = 'Paid' WHERE InvoiceID = 'INV001';
-- Expected: ORA-20007: Cannot manually set Invoice.PaymentStatus to Paid.
