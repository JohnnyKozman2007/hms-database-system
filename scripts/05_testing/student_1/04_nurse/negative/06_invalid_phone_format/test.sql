-- [NEGATIVE] Invalid Mobile Phone prefix (chk_nurse_phone)
UPDATE Nurse SET PhoneType = 'Mobile', Phone = '02279577710' WHERE NurseID = 'NRS001';
-- Expected: ORA-02290: check constraint (CHK_NURSE_PHONE) violated.
