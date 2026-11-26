-- [NEGATIVE] Invalid ContractStatus (chk_supp_status)
UPDATE Supplier SET ContractStatus = 'Pending' WHERE SupplierID = 'SUP001';
-- Expected: ORA-02290: check constraint (CHK_SUPP_STATUS) violated.
