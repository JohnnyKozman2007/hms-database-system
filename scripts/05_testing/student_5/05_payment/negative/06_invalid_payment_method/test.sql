-- [NEGATIVE] Invalid PaymentMethod (chk_pay_method)
UPDATE Payment SET PaymentMethod = 'Crypto' WHERE PaymentID = 'PAY001';
-- Expected: ORA-02290: check constraint (CHK_PAY_METHOD) violated.
