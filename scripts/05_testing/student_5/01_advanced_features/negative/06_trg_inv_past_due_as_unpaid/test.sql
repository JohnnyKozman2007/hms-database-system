-- [NEGATIVE] trg_inv_status_guard: Past DueDate inserted as Unpaid
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus)
VALUES ('INV_NEG2', 'PAT001', DATE '2023-01-01', 500.00, 0.00, DATE '2023-01-04', 'Unpaid');
-- Expected: ORA-20008: Cannot insert Invoice as Unpaid when DueDate is already in the past; must be Overdue.
