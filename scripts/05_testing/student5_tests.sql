-- ============================================================================
-- TESTING SUITE: Student 5 (Supplier, Insurance, Invoice, Payment)
-- ============================================================================

-- POSITIVE TEST 1: Insert valid Payment
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus)
VALUES (9999, 1, SYSDATE, 50.00, 'Cash', 'TXN-TEST-9999', 'Completed');
-- Expected: 1 row inserted.

-- NEGATIVE TEST 1: Attempt payment with zero or negative AmountPaid (CHECK constraint violation)
-- Expected Oracle Error: ORA-02290 (check constraint violated)
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus)
VALUES (9998, 1, SYSDATE, -100.00, 'Cash', 'TXN-TEST-9998', 'Completed');

-- NEGATIVE TEST 2: Attempt Insurance with coverage > 100% (CHECK constraint violation)
-- Expected Oracle Error: ORA-02290 (check constraint violated)
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus)
VALUES (9999, 1, 'MegaCare', 'POL-BAD-101', 125.00, SYSDATE, SYSDATE + 365, 'Active');

-- NEGATIVE TEST 3: Attempt Payment with duplicate TransactionReference (UNIQUE constraint violation)
-- Expected Oracle Error: ORA-00001 (unique constraint violated)
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus)
VALUES (9997, 1, SYSDATE, 100.00, 'Credit Card', 'TXN-2026-0001', 'Completed');
ROLLBACK;
