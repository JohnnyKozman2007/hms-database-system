-- [NEGATIVE] AmountPaid <= 0 (chk_pay_amt)
UPDATE Payment SET AmountPaid = -50 WHERE PaymentID = 'PAY001';
-- Expected: ORA-02290: check constraint (CHK_PAY_AMT) violated.
