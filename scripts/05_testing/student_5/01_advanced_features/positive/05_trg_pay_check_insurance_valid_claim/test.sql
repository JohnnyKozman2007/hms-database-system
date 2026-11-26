-- [POSITIVE] Showcase trg_pay_check_insurance (Insurance Claim succeeds with active unexpired policy)
BEGIN
    SAVEPOINT sp_test;

    INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus)
    VALUES ('INS_TRG1', 'PAT050', 'AXA Egypt', 'AXA-TRG-001', 80.00, TRUNC(SYSDATE) - 10, TRUNC(SYSDATE) + 180, 'Active');

    INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus)
    VALUES ('INV_INS1', 'PAT050', TRUNC(SYSDATE), 1000.00, 0.00, TRUNC(SYSDATE) + 3, 'Unpaid');

    INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus)
    VALUES ('PAY_INS1', 'INV_INS1', TRUNC(SYSDATE), 800.00, 'Insurance Claim', 'TXN-INS-001', 'Completed');

    DBMS_OUTPUT.PUT_LINE('Insurance Claim rows inserted: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
-- Expected: Insurance Claim rows inserted: 1.
