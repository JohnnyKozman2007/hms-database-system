-- [NEGATIVE] Invalid PhoneType (chk_supp_phone_type)
UPDATE Supplier SET PhoneType = 'Fax' WHERE SupplierID = 'SUP001';
-- Expected: ORA-02290: check constraint (CHK_SUPP_PHONE_TYPE) violated.
