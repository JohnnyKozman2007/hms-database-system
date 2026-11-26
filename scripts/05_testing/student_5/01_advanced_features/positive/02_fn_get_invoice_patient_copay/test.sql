-- Formula: Copay = ROUND(InvoiceNetAmount * (1 - ActiveCoveragePct / 100), 2)
SELECT 'InvoiceNetAmount' AS Part, NetAmount AS Val FROM Invoice WHERE InvoiceID = 'INV001'
UNION ALL
SELECT 'ActiveCoveragePct' AS Part, NVL(MAX(CoveragePercentage), 0) AS Val FROM Insurance WHERE PatientID = 'PAT001' AND InsuranceStatus = 'Active' AND ExpirationDate >= SYSDATE
UNION ALL
SELECT 'fn_get_invoice_patient_copay' AS Part, fn_get_invoice_patient_copay('INV001') AS Val FROM DUAL;
-- Expected: fn_get_invoice_patient_copay = ROUND(InvoiceNetAmount * (1 - ActiveCoveragePct / 100), 2).
