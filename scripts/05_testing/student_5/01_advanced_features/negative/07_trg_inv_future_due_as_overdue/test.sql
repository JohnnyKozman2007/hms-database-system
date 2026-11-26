-- [NEGATIVE] trg_inv_status_guard: Future DueDate inserted as Overdue
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus)
VALUES ('INV_NEG3', 'PAT001', TRUNC(SYSDATE), 500.00, 0.00, TRUNC(SYSDATE) + 3, 'Overdue');
-- Expected: ORA-20009: Cannot insert Invoice as Overdue when DueDate has not passed yet; must be Unpaid.
