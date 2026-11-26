-- [NEGATIVE] trg_pay_check_insurance: Insurance Claim rejected when patient has no active unexpired insurance
BEGIN
    SAVEPOINT sp_test;

    UPDATE Insurance SET InsuranceStatus = 'Cancelled' WHERE PatientID = 'PAT001';

    INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus)
    VALUES ('PAY_NEG1', 'INV001', TRUNC(SYSDATE), 100.00, 'Insurance Claim', 'TXN-NEG-INS-01', 'Completed');
    -- Expected: ORA-20003: Insurance Claim payment rejected: Patient has no active, unexpired insurance policy.

    ROLLBACK TO sp_test;
END;
