-- [POSITIVE] Showcase trg_pay_balance_and_status (Payment auto-updates Invoice.PaymentStatus)
-- Formula: NetAmount = TotalAmount (1000) + 10% Tax (100) - Discount (0) = 1100.00
DECLARE
    v_net    Invoice.NetAmount%TYPE;
    v_status Invoice.PaymentStatus%TYPE;
BEGIN
    SAVEPOINT sp_test;

    INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus)
    VALUES ('INV_TRG1', 'PAT001', TRUNC(SYSDATE), 1000.00, 0.00, TRUNC(SYSDATE) + 3, 'Unpaid');

    -- Step 1: Partial payment (500 / 1100) -> PaymentStatus = 'Partially Paid'
    INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus)
    VALUES ('PAY_TRG1', 'INV_TRG1', TRUNC(SYSDATE), 500.00, 'Cash', 'TXN-TRG-001', 'Completed');

    SELECT NetAmount, PaymentStatus INTO v_net, v_status FROM Invoice WHERE InvoiceID = 'INV_TRG1';
    DBMS_OUTPUT.PUT_LINE('After 500 paid -> NetAmount: ' || v_net || ' | Status: ' || v_status);

    -- Step 2: Remaining payment (+600 = 1100 / 1100) -> PaymentStatus = 'Paid'
    INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus)
    VALUES ('PAY_TRG2', 'INV_TRG1', TRUNC(SYSDATE), 600.00, 'Cash', 'TXN-TRG-002', 'Completed');

    SELECT NetAmount, PaymentStatus INTO v_net, v_status FROM Invoice WHERE InvoiceID = 'INV_TRG1';
    DBMS_OUTPUT.PUT_LINE('After 1100 paid -> NetAmount: ' || v_net || ' | Status: ' || v_status);

    ROLLBACK TO sp_test;
END;
-- Expected: NetAmount = 1100; Status flips Unpaid -> Partially Paid -> Paid.
