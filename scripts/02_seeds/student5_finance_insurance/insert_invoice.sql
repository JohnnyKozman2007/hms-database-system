-- ============================================================================
-- SEED DATA: Invoice (Student 5)
-- Target: Minimum 200 invoices
-- ID Range: 1 to 200
-- Foreign Keys: PatientID (1..100)
-- ============================================================================

INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, TaxAmount, Discount, DueDate, PaymentStatus)
VALUES (1, 1, DATE '2026-01-16', 1500.00, 150.00, 50.00, DATE '2026-02-16', 'Paid');

-- Add remaining invoices (2 to 200) following this exact pattern.
COMMIT;
