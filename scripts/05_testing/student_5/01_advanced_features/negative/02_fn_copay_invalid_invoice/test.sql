-- [NEGATIVE] fn_get_invoice_patient_copay with non-existent InvoiceID
SELECT fn_get_invoice_patient_copay('INV999') FROM DUAL;
-- Expected: ORA-20041: Invoice ID INV999 does not exist.
