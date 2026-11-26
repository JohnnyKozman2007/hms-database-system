-- [NEGATIVE] Invalid Phone format/length (chk_supp_phone)
UPDATE Supplier SET Phone = '12345' WHERE SupplierID = 'SUP001';
-- Expected: ORA-02290: check constraint (CHK_SUPP_PHONE) violated.
