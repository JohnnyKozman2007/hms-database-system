-- [NEGATIVE] Future Payment.PaymentDate (trg_pay_date_max)
UPDATE Payment SET PaymentDate = SYSDATE + 1 WHERE PaymentID = 'PAY001';
-- Expected: ORA-20001: Payment.PaymentDate cannot be in the future (exceeds SYSDATE).
