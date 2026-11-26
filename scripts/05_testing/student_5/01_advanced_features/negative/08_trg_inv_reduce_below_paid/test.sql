-- [NEGATIVE] trg_inv_status_guard: Reduce NetAmount below completed payments on INV002
UPDATE Invoice SET TotalAmount = 10.00, Discount = 0.00 WHERE InvoiceID = 'INV002';
-- Expected: ORA-20002: Invoice NetAmount cannot be reduced below already-completed payments.
