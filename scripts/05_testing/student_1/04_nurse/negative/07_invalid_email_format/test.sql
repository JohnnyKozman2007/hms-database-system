-- [NEGATIVE] Invalid Email format (chk_nurse_email_fmt)
UPDATE Nurse SET Email = 'no-at-sign.org' WHERE NurseID = 'NRS001';
-- Expected: ORA-02290: check constraint (CHK_NURSE_EMAIL_FMT) violated.
