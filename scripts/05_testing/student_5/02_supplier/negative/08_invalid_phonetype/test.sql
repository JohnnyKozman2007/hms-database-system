-- [NEGATIVE] Invalid PhoneType (chk_supp_phone_type / chk_supp_phone)
UPDATE Supplier SET PhoneType = 'Fax' WHERE SupplierID = 'SUP001';
-- Expected: ORA-02290: check constraint (CHK_SUPP_PHONE_TYPE / CHK_SUPP_PHONE) violated.
-- Note: Oracle does not guarantee evaluation order between two overlapping CHECK constraints.
