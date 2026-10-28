-- ============================================================================
-- SEED DATA: Payment (Student 5)
-- Target: Minimum 250 payments
-- ID Range: 1 to 250
-- Foreign Keys: InvoiceID (1..200)
-- ============================================================================

INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus)
VALUES (1, 1, DATE '2026-01-18', 1600.00, 'Credit Card', 'TXN-2026-0001', 'Completed');

-- Add remaining payments (2 to 250) following this exact pattern.
COMMIT;
