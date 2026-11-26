-- [NEGATIVE] TransactionReference < 4 chars or invalid chars (chk_pay_ref_fmt)
UPDATE Payment SET TransactionReference = 'TX' WHERE PaymentID = 'PAY001';
-- Expected: ORA-02290: check constraint (CHK_PAY_REF_FMT) violated.
