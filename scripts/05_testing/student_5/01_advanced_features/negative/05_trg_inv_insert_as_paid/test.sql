-- [NEGATIVE] trg_inv_status_guard: Direct INSERT of Invoice as Paid
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus)
VALUES ('INV_NEG1', 'PAT001', TRUNC(SYSDATE), 500.00, 0.00, TRUNC(SYSDATE) + 3, 'Paid');
-- Expected: ORA-20007: New invoices cannot be inserted directly as Paid or Partially Paid.
