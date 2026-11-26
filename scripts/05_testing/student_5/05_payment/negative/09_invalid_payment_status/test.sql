-- [NEGATIVE] Invalid PaymentStatus (chk_pay_status)
UPDATE Payment SET PaymentStatus = 'Cancelled' WHERE PaymentID = 'PAY001';
-- Expected: ORA-02290: check constraint (CHK_PAY_STATUS) violated.
