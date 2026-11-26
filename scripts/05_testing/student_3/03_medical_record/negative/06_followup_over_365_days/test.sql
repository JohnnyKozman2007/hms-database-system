-- [NEGATIVE] FollowUpDate > RecordDate + 365 (chk_mr_dates)
UPDATE MedicalRecord SET FollowUpDate = DATE '2029-01-01' WHERE RecordID = 'MR001';
-- Expected: ORA-02290: check constraint (CHK_MR_DATES) violated.
