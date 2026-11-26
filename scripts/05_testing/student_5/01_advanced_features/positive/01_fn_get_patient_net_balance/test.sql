-- Formula: NetBalance = TotalBilled - TotalCompletedPaid
SELECT 'TotalBilled' AS Part, NVL(SUM(NetAmount), 0) AS Val FROM Invoice WHERE PatientID = 'PAT001'
UNION ALL
SELECT 'TotalCompletedPaid' AS Part, NVL(SUM(AmountPaid), 0) AS Val FROM Payment WHERE PaymentStatus = 'Completed' AND InvoiceID IN (SELECT InvoiceID FROM Invoice WHERE PatientID = 'PAT001')
UNION ALL
SELECT 'fn_get_patient_net_balance' AS Part, fn_get_patient_net_balance('PAT001') AS Val FROM DUAL;
-- Expected: fn_get_patient_net_balance = TotalBilled - TotalCompletedPaid.
