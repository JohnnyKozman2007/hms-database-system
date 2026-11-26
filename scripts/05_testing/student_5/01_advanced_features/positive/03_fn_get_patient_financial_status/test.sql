-- Formula: TotalOwed = BaseBalance + SUM(UnpaidOverdueBalance * 0.10 * WeeksOverdue)
SELECT 'BaseBalance' AS Part, TO_CHAR(fn_get_patient_net_balance('PAT001')) AS Val FROM DUAL
UNION ALL
SELECT 'OverdueInvoices' AS Part, TO_CHAR(COUNT(*)) AS Val FROM Invoice WHERE PatientID = 'PAT001' AND PaymentStatus <> 'Paid' AND DueDate < SYSDATE
UNION ALL
SELECT 'MaxWeeksOverdue' AS Part, TO_CHAR(NVL(MAX(FLOOR((SYSDATE - DueDate) / 7)), 0)) AS Val FROM Invoice WHERE PatientID = 'PAT001' AND PaymentStatus <> 'Paid' AND DueDate < SYSDATE
UNION ALL
SELECT 'fn_get_patient_financial_status' AS Part, fn_get_patient_financial_status('PAT001') AS Val FROM DUAL;
-- Expected: Status & TotalOwed match BaseBalance, OverdueInvoices, and MaxWeeksOverdue.
