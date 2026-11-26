-- ============================================================================
-- ORACLE APEX SQL SCRIPT: STUDENT_5
-- Upload in: Oracle APEX -> SQL Workshop -> SQL Scripts -> Upload -> Run
-- All positive DML tests use SAVEPOINT + ROLLBACK (zero permanent changes).
-- ============================================================================

-- [01] student_5\01_advanced_features\negative\01_fn_net_balance_invalid_patient
-- [NEGATIVE] fn_get_patient_net_balance with non-existent PatientID
SELECT fn_get_patient_net_balance('PAT999') FROM DUAL;
-- Expected: ORA-20040: Patient ID PAT999 does not exist.

-- [02] student_5\01_advanced_features\negative\02_fn_copay_invalid_invoice
-- [NEGATIVE] fn_get_invoice_patient_copay with non-existent InvoiceID
SELECT fn_get_invoice_patient_copay('INV999') FROM DUAL;
-- Expected: ORA-20041: Invoice ID INV999 does not exist.

-- [03] student_5\01_advanced_features\negative\03_trg_ins_past_expiry_as_active
-- [NEGATIVE] trg_ins_status_date_guard: Active status with past ExpirationDate
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus)
VALUES ('INS_NEG1', 'PAT001', 'AXA Egypt', 'AXA-NEG-001', 80.00, DATE '2022-01-01', DATE '2023-01-01', 'Active');
-- Expected: ORA-20005: Cannot set InsuranceStatus to Active when ExpirationDate is in the past; must be Expired.

-- [04] student_5\01_advanced_features\negative\04_trg_ins_future_expiry_as_expired
-- [NEGATIVE] trg_ins_status_date_guard: Expired status with future ExpirationDate
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus)
VALUES ('INS_NEG2', 'PAT001', 'Bupa Egypt', 'BUPA-NEG-002', 80.00, TRUNC(SYSDATE), TRUNC(SYSDATE) + 365, 'Expired');
-- Expected: ORA-20006: Cannot set InsuranceStatus to Expired when ExpirationDate has not passed yet.

-- [05] student_5\01_advanced_features\negative\05_trg_inv_insert_as_paid
-- [NEGATIVE] trg_inv_status_guard: Direct INSERT of Invoice as Paid
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus)
VALUES ('INV_NEG1', 'PAT001', TRUNC(SYSDATE), 500.00, 0.00, TRUNC(SYSDATE) + 3, 'Paid');
-- Expected: ORA-20007: New invoices cannot be inserted directly as Paid or Partially Paid.

-- [06] student_5\01_advanced_features\negative\06_trg_inv_past_due_as_unpaid
-- [NEGATIVE] trg_inv_status_guard: Past DueDate inserted as Unpaid
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus)
VALUES ('INV_NEG2', 'PAT001', DATE '2023-01-01', 500.00, 0.00, DATE '2023-01-04', 'Unpaid');
-- Expected: ORA-20008: Cannot insert Invoice as Unpaid when DueDate is already in the past; must be Overdue.

-- [07] student_5\01_advanced_features\negative\07_trg_inv_future_due_as_overdue
-- [NEGATIVE] trg_inv_status_guard: Future DueDate inserted as Overdue
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus)
VALUES ('INV_NEG3', 'PAT001', TRUNC(SYSDATE), 500.00, 0.00, TRUNC(SYSDATE) + 3, 'Overdue');
-- Expected: ORA-20009: Cannot insert Invoice as Overdue when DueDate has not passed yet; must be Unpaid.

-- [08] student_5\01_advanced_features\negative\08_trg_inv_reduce_below_paid
-- [NEGATIVE] trg_inv_status_guard: Reduce NetAmount below completed payments on INV002
UPDATE Invoice SET TotalAmount = 10.00, Discount = 0.00 WHERE InvoiceID = 'INV002';
-- Expected: ORA-20002: Invoice NetAmount cannot be reduced below already-completed payments.

-- [09] student_5\01_advanced_features\negative\09_trg_inv_manual_status_mismatch
-- [NEGATIVE] trg_inv_status_guard: Manually set INV001 PaymentStatus to Paid with 0 payments
UPDATE Invoice SET PaymentStatus = 'Paid' WHERE InvoiceID = 'INV001';
-- Expected: ORA-20007: Cannot manually set Invoice.PaymentStatus to Paid.

-- [10] student_5\01_advanced_features\negative\10_trg_pay_insurance_claim_without_active_policy
-- [NEGATIVE] trg_pay_check_insurance: Insurance Claim rejected when patient has no active unexpired insurance
BEGIN
    SAVEPOINT sp_test;

    UPDATE Insurance SET InsuranceStatus = 'Cancelled' WHERE PatientID = 'PAT001';

    INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus)
    VALUES ('PAY_NEG1', 'INV001', TRUNC(SYSDATE), 100.00, 'Insurance Claim', 'TXN-NEG-INS-01', 'Completed');
    -- Expected: ORA-20003: Insurance Claim payment rejected: Patient has no active, unexpired insurance policy.

    ROLLBACK TO sp_test;
END;
/

-- [11] student_5\01_advanced_features\negative\11_trg_pay_date_before_invoice_date
-- [NEGATIVE] trg_pay_balance_and_status: PaymentDate earlier than InvoiceDate
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus)
VALUES ('PAY_NEG2', 'INV001', DATE '2020-01-01', 100.00, 'Cash', 'TXN-NEG-DT-01', 'Completed');
-- Expected: ORA-20004: PaymentDate cannot be earlier than Invoice.InvoiceDate for Invoice INV001.

-- [12] student_5\01_advanced_features\positive\01_fn_get_patient_net_balance
-- Formula: NetBalance = TotalBilled - TotalCompletedPaid
SELECT 'TotalBilled' AS Part, NVL(SUM(NetAmount), 0) AS Val FROM Invoice WHERE PatientID = 'PAT001'
UNION ALL
SELECT 'TotalCompletedPaid' AS Part, NVL(SUM(AmountPaid), 0) AS Val FROM Payment WHERE PaymentStatus = 'Completed' AND InvoiceID IN (SELECT InvoiceID FROM Invoice WHERE PatientID = 'PAT001')
UNION ALL
SELECT 'fn_get_patient_net_balance' AS Part, fn_get_patient_net_balance('PAT001') AS Val FROM DUAL;
-- Expected: fn_get_patient_net_balance = TotalBilled - TotalCompletedPaid.

-- [13] student_5\01_advanced_features\positive\02_fn_get_invoice_patient_copay
-- Formula: Copay = ROUND(InvoiceNetAmount * (1 - ActiveCoveragePct / 100), 2)
SELECT 'InvoiceNetAmount' AS Part, NetAmount AS Val FROM Invoice WHERE InvoiceID = 'INV001'
UNION ALL
SELECT 'ActiveCoveragePct' AS Part, NVL(MAX(CoveragePercentage), 0) AS Val FROM Insurance WHERE PatientID = 'PAT001' AND InsuranceStatus = 'Active' AND ExpirationDate >= SYSDATE
UNION ALL
SELECT 'fn_get_invoice_patient_copay' AS Part, fn_get_invoice_patient_copay('INV001') AS Val FROM DUAL;
-- Expected: fn_get_invoice_patient_copay = ROUND(InvoiceNetAmount * (1 - ActiveCoveragePct / 100), 2).

-- [14] student_5\01_advanced_features\positive\03_fn_get_patient_financial_status
-- Formula: TotalOwed = BaseBalance + SUM(UnpaidOverdueBalance * 0.10 * WeeksOverdue)
SELECT 'BaseBalance' AS Part, TO_CHAR(fn_get_patient_net_balance('PAT001')) AS Val FROM DUAL
UNION ALL
SELECT 'OverdueInvoices' AS Part, TO_CHAR(COUNT(*)) AS Val FROM Invoice WHERE PatientID = 'PAT001' AND PaymentStatus <> 'Paid' AND DueDate < SYSDATE
UNION ALL
SELECT 'MaxWeeksOverdue' AS Part, TO_CHAR(NVL(MAX(FLOOR((SYSDATE - DueDate) / 7)), 0)) AS Val FROM Invoice WHERE PatientID = 'PAT001' AND PaymentStatus <> 'Paid' AND DueDate < SYSDATE
UNION ALL
SELECT 'fn_get_patient_financial_status' AS Part, fn_get_patient_financial_status('PAT001') AS Val FROM DUAL;
-- Expected: Status & TotalOwed match BaseBalance, OverdueInvoices, and MaxWeeksOverdue.

-- [15] student_5\01_advanced_features\positive\04_trg_pay_balance_and_status_auto_paid
-- Expected: NetAmount = 1100; Status flips Unpaid -> Partially Paid -> Paid.
-- [POSITIVE] Showcase trg_pay_balance_and_status (Payment auto-updates Invoice.PaymentStatus)
-- Formula: NetAmount = TotalAmount (1000) + 10% Tax (100) - Discount (0) = 1100.00
DECLARE
    v_net    Invoice.NetAmount%TYPE;
    v_status Invoice.PaymentStatus%TYPE;
BEGIN
    SAVEPOINT sp_test;

    INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus)
    VALUES ('INV_TRG1', 'PAT001', TRUNC(SYSDATE), 1000.00, 0.00, TRUNC(SYSDATE) + 3, 'Unpaid');

    -- Step 1: Partial payment (500 / 1100) -> PaymentStatus = 'Partially Paid'
    INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus)
    VALUES ('PAY_TRG1', 'INV_TRG1', TRUNC(SYSDATE), 500.00, 'Cash', 'TXN-TRG-001', 'Completed');

    SELECT NetAmount, PaymentStatus INTO v_net, v_status FROM Invoice WHERE InvoiceID = 'INV_TRG1';
    DBMS_OUTPUT.PUT_LINE('After 500 paid -> NetAmount: ' || v_net || ' | Status: ' || v_status);

    -- Step 2: Remaining payment (+600 = 1100 / 1100) -> PaymentStatus = 'Paid'
    INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus)
    VALUES ('PAY_TRG2', 'INV_TRG1', TRUNC(SYSDATE), 600.00, 'Cash', 'TXN-TRG-002', 'Completed');

    SELECT NetAmount, PaymentStatus INTO v_net, v_status FROM Invoice WHERE InvoiceID = 'INV_TRG1';
    DBMS_OUTPUT.PUT_LINE('After 1100 paid -> NetAmount: ' || v_net || ' | Status: ' || v_status);

    ROLLBACK TO sp_test;
END;
/

-- [16] student_5\01_advanced_features\positive\05_trg_pay_check_insurance_valid_claim
-- Expected: Insurance Claim rows inserted: 1.
-- [POSITIVE] Showcase trg_pay_check_insurance (Insurance Claim succeeds with active unexpired policy)
BEGIN
    SAVEPOINT sp_test;

    INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus)
    VALUES ('INS_TRG1', 'PAT050', 'AXA Egypt', 'AXA-TRG-001', 80.00, TRUNC(SYSDATE) - 10, TRUNC(SYSDATE) + 180, 'Active');

    INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus)
    VALUES ('INV_INS1', 'PAT050', TRUNC(SYSDATE), 1000.00, 0.00, TRUNC(SYSDATE) + 3, 'Unpaid');

    INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus)
    VALUES ('PAY_INS1', 'INV_INS1', TRUNC(SYSDATE), 800.00, 'Insurance Claim', 'TXN-INS-001', 'Completed');

    DBMS_OUTPUT.PUT_LINE('Insurance Claim rows inserted: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
/

-- [17] student_5\02_supplier\negative\01_duplicate_pk
-- [NEGATIVE] Duplicate SupplierID (pk_supplier)
INSERT INTO Supplier (SupplierID, CompanyName, ContactPerson, Phone, Email, Street, City, PostalCode)
VALUES ('SUP001', 'Dup Supplier', 'Ali Hassan', '0224189901', 'dup.sup@hms.eg', 'Street 1', 'Cairo', '11511');
-- Expected: ORA-00001: unique constraint (PK_SUPPLIER) violated.

-- [18] student_5\02_supplier\negative\02_invalid_supplier_id
-- [NEGATIVE] Invalid SupplierID format (chk_supp_id)
INSERT INTO Supplier (SupplierID, CompanyName, ContactPerson, Phone, Email, Street, City, PostalCode)
VALUES ('SUP@1', 'Bad ID Co', 'Ali Hassan', '0224189902', 'bad.id@hms.eg', 'Street 1', 'Cairo', '11511');
-- Expected: ORA-02290: check constraint (CHK_SUPP_ID) violated.

-- [19] student_5\02_supplier\negative\03_duplicate_company_name
-- [NEGATIVE] Duplicate CompanyName (uq_supp_name)
UPDATE Supplier SET CompanyName = 'EIPICO Medical Supplies' WHERE SupplierID = 'SUP001';
-- Expected: ORA-00001: unique constraint (UQ_SUPP_NAME) violated.

-- [20] student_5\02_supplier\negative\04_company_name_too_short
-- [NEGATIVE] CompanyName < 2 chars (chk_supp_company_len)
UPDATE Supplier SET CompanyName = 'A' WHERE SupplierID = 'SUP001';
-- Expected: ORA-02290: check constraint (CHK_SUPP_COMPANY_LEN) violated.

-- [21] student_5\02_supplier\negative\05_null_company_name
-- [NEGATIVE] NULL CompanyName
UPDATE Supplier SET CompanyName = NULL WHERE SupplierID = 'SUP001';
-- Expected: ORA-01407: cannot update (SUPPLIER.COMPANYNAME) to NULL.

-- [22] student_5\02_supplier\negative\06_invalid_contact_person
-- [NEGATIVE] ContactPerson with digits or < 3 chars (chk_supp_contact_fmt)
UPDATE Supplier SET ContactPerson = 'Ali123' WHERE SupplierID = 'SUP001';
-- Expected: ORA-02290: check constraint (CHK_SUPP_CONTACT_FMT) violated.

-- [23] student_5\02_supplier\negative\07_duplicate_phone
-- [NEGATIVE] Duplicate Phone (uq_supp_phone)
UPDATE Supplier SET Phone = '0224180002' WHERE SupplierID = 'SUP001';
-- Expected: ORA-00001: unique constraint (UQ_SUPP_PHONE) violated.

-- [24] student_5\02_supplier\negative\08_invalid_phonetype
-- [NEGATIVE] Invalid PhoneType (chk_supp_phone_type)
UPDATE Supplier SET PhoneType = 'Fax' WHERE SupplierID = 'SUP001';
-- Expected: ORA-02290: check constraint (CHK_SUPP_PHONE_TYPE) violated.

-- [25] student_5\02_supplier\negative\09_invalid_phone_format
-- [NEGATIVE] Invalid Phone format/length (chk_supp_phone)
UPDATE Supplier SET Phone = '12345' WHERE SupplierID = 'SUP001';
-- Expected: ORA-02290: check constraint (CHK_SUPP_PHONE) violated.

-- [26] student_5\02_supplier\negative\10_duplicate_email
-- [NEGATIVE] Duplicate Email (uq_supp_email)
UPDATE Supplier SET Email = 'supply@eipico.eg' WHERE SupplierID = 'SUP001';
-- Expected: ORA-00001: unique constraint (UQ_SUPP_EMAIL) violated.

-- [27] student_5\02_supplier\negative\11_invalid_email_format
-- [NEGATIVE] Invalid Email format (chk_supp_email_fmt)
UPDATE Supplier SET Email = 'bad-email' WHERE SupplierID = 'SUP001';
-- Expected: ORA-02290: check constraint (CHK_SUPP_EMAIL_FMT) violated.

-- [28] student_5\02_supplier\negative\12_street_too_short
-- [NEGATIVE] Street < 3 chars (chk_supp_street_len)
UPDATE Supplier SET Street = 'AB' WHERE SupplierID = 'SUP001';
-- Expected: ORA-02290: check constraint (CHK_SUPP_STREET_LEN) violated.

-- [29] student_5\02_supplier\negative\13_invalid_city
-- [NEGATIVE] City with digits or < 2 chars (chk_supp_city_fmt)
UPDATE Supplier SET City = 'Cairo1' WHERE SupplierID = 'SUP001';
-- Expected: ORA-02290: check constraint (CHK_SUPP_CITY_FMT) violated.

-- [30] student_5\02_supplier\negative\14_invalid_postal_code
-- [NEGATIVE] Invalid PostalCode characters (chk_supp_postal)
UPDATE Supplier SET PostalCode = '115@1' WHERE SupplierID = 'SUP001';
-- Expected: ORA-02290: check constraint (CHK_SUPP_POSTAL) violated.

-- [31] student_5\02_supplier\negative\15_invalid_contract_status
-- [NEGATIVE] Invalid ContractStatus (chk_supp_status)
UPDATE Supplier SET ContractStatus = 'Pending' WHERE SupplierID = 'SUP001';
-- Expected: ORA-02290: check constraint (CHK_SUPP_STATUS) violated.

-- [32] student_5\02_supplier\positive\01_min_boundaries
-- Expected: 1 row inserted.
-- [POSITIVE - Min Boundaries] 2-char CompanyName, 3-char ContactPerson/Street, 2-char City, 9-digit Landline
BEGIN
    SAVEPOINT sp_test;
    INSERT INTO Supplier (SupplierID, CompanyName, ContactPerson, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, ContractStatus)
    VALUES ('S1', 'Co', 'Ali', '022418901', 'Landline', 's@co.eg', '1', 'St1', 'Al', '1', 'Active');
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
/

-- [33] student_5\02_supplier\positive\02_max_boundaries
-- Expected: 1 row inserted.
-- [POSITIVE - Max Boundaries] 11-digit Mobile, Under Review status
BEGIN
    SAVEPOINT sp_test;
    INSERT INTO Supplier (SupplierID, CompanyName, ContactPerson, Phone, PhoneType, Email, BuildingNumber, Street, City, PostalCode, ContractStatus)
    VALUES ('SUP_MAX_01', 'International Medical Logistics Corp', 'O''Connor', '01061899999', 'Mobile', 'sup.max@medcorp.eg', '99B', 'Tenth of Ramadan Industrial Zone', 'Alexandria', '21500', 'Under Review');
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
/

-- [34] student_5\02_supplier\positive\03_defaults_and_nulls
-- Expected: 1 row inserted with PhoneType = 'Landline' and ContractStatus = 'Active'.
-- [POSITIVE - Defaults & NULLs] Omit PhoneType ('Landline') & ContractStatus ('Active'); BuildingNumber = NULL
BEGIN
    SAVEPOINT sp_test;
    INSERT INTO Supplier (SupplierID, CompanyName, ContactPerson, Phone, Email, BuildingNumber, Street, City, PostalCode)
    VALUES ('SUP_DEF_01', 'Delta Pharma Supplies', 'Hossam Adel', '0224189002', 'delta@pharma.eg', NULL, 'Corniche El-Nil', 'Cairo', '11511');
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
/

-- [35] student_5\02_supplier\positive\04_valid_update
-- Expected: 1 row updated.
-- [POSITIVE - Valid UPDATE]
BEGIN
    SAVEPOINT sp_test;
    UPDATE Supplier SET ContractStatus = 'Inactive' WHERE SupplierID = 'SUP001';
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
/

-- [36] student_5\03_insurance\negative\01_duplicate_pk
-- [NEGATIVE] Duplicate InsuranceID (pk_insurance)
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate)
VALUES ('INS001', 'PAT050', 'AXA Egypt', 'POL-DUP-001', 80.00, TRUNC(SYSDATE), TRUNC(SYSDATE) + 180);
-- Expected: ORA-00001: unique constraint (PK_INSURANCE) violated.

-- [37] student_5\03_insurance\negative\02_invalid_insurance_id
-- [NEGATIVE] Invalid InsuranceID format (chk_ins_id)
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate)
VALUES ('INS@1', 'PAT050', 'AXA Egypt', 'POL-BAD-001', 80.00, TRUNC(SYSDATE), TRUNC(SYSDATE) + 180);
-- Expected: ORA-02290: check constraint (CHK_INS_ID) violated.

-- [38] student_5\03_insurance\negative\03_invalid_patient_fk
-- [NEGATIVE] Non-existent PatientID (fk_ins_patient)
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate)
VALUES ('INS_FK1', 'PAT999', 'AXA Egypt', 'POL-FK-001', 80.00, TRUNC(SYSDATE), TRUNC(SYSDATE) + 180);
-- Expected: ORA-02291: integrity constraint (FK_INS_PATIENT) violated.

-- [39] student_5\03_insurance\negative\04_invalid_company
-- [NEGATIVE] Invalid InsuranceCompany (chk_ins_company)
UPDATE Insurance SET InsuranceCompany = 'Unknown Insurance' WHERE InsuranceID = 'INS001';
-- Expected: ORA-02290: check constraint (CHK_INS_COMPANY) violated.

-- [40] student_5\03_insurance\negative\05_duplicate_policy_number
-- [NEGATIVE] Duplicate PolicyNumber (uq_ins_policy)
INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate)
VALUES ('INS_POL1', 'PAT050', 'Bupa Egypt', (SELECT PolicyNumber FROM Insurance WHERE InsuranceID = 'INS001'), 80.00, TRUNC(SYSDATE), TRUNC(SYSDATE) + 180);
-- Expected: ORA-00001: unique constraint (UQ_INS_POLICY) violated.

-- [41] student_5\03_insurance\negative\06_invalid_policy_format
-- [NEGATIVE] PolicyNumber < 4 chars or invalid chars (chk_ins_policy_fmt)
UPDATE Insurance SET PolicyNumber = 'P1' WHERE InsuranceID = 'INS001';
-- Expected: ORA-02290: check constraint (CHK_INS_POLICY_FMT) violated.

-- [42] student_5\03_insurance\negative\07_coverage_negative
-- [NEGATIVE] CoveragePercentage < 0 (chk_ins_cov)
UPDATE Insurance SET CoveragePercentage = -5 WHERE InsuranceID = 'INS001';
-- Expected: ORA-02290: check constraint (CHK_INS_COV) violated.

-- [43] student_5\03_insurance\negative\08_coverage_over_100
-- [NEGATIVE] CoveragePercentage > 100 (chk_ins_cov)
UPDATE Insurance SET CoveragePercentage = 105 WHERE InsuranceID = 'INS001';
-- Expected: ORA-02290: check constraint (CHK_INS_COV) violated.

-- [44] student_5\03_insurance\negative\09_start_date_before_2020
-- [NEGATIVE] StartDate < 2020-01-01 (chk_ins_start_date)
UPDATE Insurance SET StartDate = DATE '2019-12-31' WHERE InsuranceID = 'INS001';
-- Expected: ORA-02290: check constraint (CHK_INS_START_DATE) violated.

-- [45] student_5\03_insurance\negative\10_expiration_before_start
-- [NEGATIVE] ExpirationDate <= StartDate (chk_ins_dates; Cancelled bypasses trg_ins_status_date_guard)
UPDATE Insurance SET InsuranceStatus = 'Cancelled', ExpirationDate = StartDate WHERE InsuranceID = 'INS001';
-- Expected: ORA-02290: check constraint (CHK_INS_DATES) violated.

-- [46] student_5\03_insurance\negative\11_invalid_status
-- [NEGATIVE] Invalid InsuranceStatus (chk_ins_status)
UPDATE Insurance SET InsuranceStatus = 'Pending' WHERE InsuranceID = 'INS001';
-- Expected: ORA-02290: check constraint (CHK_INS_STATUS) violated.

-- [47] student_5\03_insurance\negative\12_duplicate_active_company_for_patient
-- [NEGATIVE] Second Active policy for same Patient + InsuranceCompany (uq_ins_one_active_comp)
BEGIN
    SAVEPOINT sp_test;

    INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus)
    VALUES ('INS_ACT1', 'PAT060', 'AXA Egypt', 'AXA-ACT-001', 70.00, TRUNC(SYSDATE) - 5, TRUNC(SYSDATE) + 180, 'Active');

    INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus)
    VALUES ('INS_ACT2', 'PAT060', 'AXA Egypt', 'AXA-ACT-002', 80.00, TRUNC(SYSDATE), TRUNC(SYSDATE) + 365, 'Active');
    -- Expected: ORA-00001: unique constraint (UQ_INS_ONE_ACTIVE_COMP) violated.

    ROLLBACK TO sp_test;
END;
/

-- [48] student_5\03_insurance\positive\01_min_boundaries
-- Expected: 1 row inserted.
-- [POSITIVE - Min Boundaries] CoveragePercentage = 0, StartDate = 2020-01-01, 4-char PolicyNumber
BEGIN
    SAVEPOINT sp_test;
    INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus)
    VALUES ('I1', 'PAT001', 'AXA Egypt', 'P001', 0.00, DATE '2020-01-01', DATE '2020-01-02', 'Expired');
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
/

-- [49] student_5\03_insurance\positive\02_max_boundaries
-- Expected: 1 row inserted.
-- [POSITIVE - Max Boundaries] CoveragePercentage = 100, StartDate = TRUNC(SYSDATE)
BEGIN
    SAVEPOINT sp_test;
    INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate, InsuranceStatus)
    VALUES ('INS_MAX_01', 'PAT002', 'Delta Insurance', 'DEL-MAX-2026-01', 100.00, TRUNC(SYSDATE), TRUNC(SYSDATE) + 365, 'Active');
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
/

-- [50] student_5\03_insurance\positive\03_defaults_and_nulls
-- Expected: 1 row inserted with InsuranceStatus = 'Active'.
-- [POSITIVE - Defaults] Omit InsuranceStatus (DEFAULT 'Active')
BEGIN
    SAVEPOINT sp_test;
    INSERT INTO Insurance (InsuranceID, PatientID, InsuranceCompany, PolicyNumber, CoveragePercentage, StartDate, ExpirationDate)
    VALUES ('INS_DEF_01', 'PAT003', 'GIG Egypt', 'GIG-DEF-001', 80.00, TRUNC(SYSDATE), TRUNC(SYSDATE) + 180);
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
/

-- [51] student_5\03_insurance\positive\04_valid_update
-- Expected: 1 row updated.
-- [POSITIVE - Valid UPDATE]
BEGIN
    SAVEPOINT sp_test;
    UPDATE Insurance SET CoveragePercentage = 90.00, InsuranceStatus = 'Suspended' WHERE InsuranceID = 'INS001';
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
/

-- [52] student_5\04_invoice\negative\01_duplicate_pk
-- [NEGATIVE] Duplicate InvoiceID (pk_invoice)
INSERT INTO Invoice (InvoiceID, PatientID, TotalAmount)
VALUES ('INV001', 'PAT001', 500.00);
-- Expected: ORA-00001: unique constraint (PK_INVOICE) violated.

-- [53] student_5\04_invoice\negative\02_invalid_invoice_id
-- [NEGATIVE] Invalid InvoiceID format (chk_inv_id)
INSERT INTO Invoice (InvoiceID, PatientID, TotalAmount)
VALUES ('INV@1', 'PAT001', 500.00);
-- Expected: ORA-02290: check constraint (CHK_INV_ID) violated.

-- [54] student_5\04_invoice\negative\03_invalid_patient_fk
-- [NEGATIVE] Non-existent PatientID (fk_inv_patient)
INSERT INTO Invoice (InvoiceID, PatientID, TotalAmount)
VALUES ('INV_FK1', 'PAT999', 500.00);
-- Expected: ORA-02291: integrity constraint (FK_INV_PATIENT) violated.

-- [55] student_5\04_invoice\negative\04_date_before_2020
-- [NEGATIVE] InvoiceDate < 2020-01-01 (chk_inv_date_lower)
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, DueDate, PaymentStatus)
VALUES ('INV_DT1', 'PAT001', DATE '2019-12-31', 500.00, DATE '2020-01-01', 'Overdue');
-- Expected: ORA-02290: check constraint (CHK_INV_DATE_LOWER) violated.

-- [56] student_5\04_invoice\negative\05_total_amount_zero
-- [NEGATIVE] TotalAmount <= 0 (chk_inv_total)
UPDATE Invoice SET TotalAmount = 0 WHERE InvoiceID = 'INV001';
-- Expected: ORA-02290: check constraint (CHK_INV_TOTAL) violated.

-- [57] student_5\04_invoice\negative\06_negative_discount
-- [NEGATIVE] Discount < 0 (chk_inv_disc)
UPDATE Invoice SET Discount = -10 WHERE InvoiceID = 'INV001';
-- Expected: ORA-02290: check constraint (CHK_INV_DISC) violated.

-- [58] student_5\04_invoice\negative\07_discount_exceeds_total
-- [NEGATIVE] Discount > TotalAmount (chk_inv_disc; INSERT hits CHECK directly)
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus)
VALUES ('INV_DSC1', 'PAT001', TRUNC(SYSDATE), 500.00, 600.00, TRUNC(SYSDATE) + 3, 'Unpaid');
-- Expected: ORA-02290: check constraint (CHK_INV_DISC) violated.

-- [59] student_5\04_invoice\negative\08_due_date_before_invoice_date
-- [NEGATIVE] DueDate < InvoiceDate (chk_inv_dates)
UPDATE Invoice SET DueDate = InvoiceDate - 1 WHERE InvoiceID = 'INV001';
-- Expected: ORA-02290: check constraint (CHK_INV_DATES) violated.

-- [60] student_5\04_invoice\negative\09_due_date_over_3_days
-- [NEGATIVE] DueDate > InvoiceDate + 3 (chk_inv_dates)
UPDATE Invoice SET DueDate = InvoiceDate + 4 WHERE InvoiceID = 'INV001';
-- Expected: ORA-02290: check constraint (CHK_INV_DATES) violated.

-- [61] student_5\04_invoice\negative\10_invalid_payment_status
-- [NEGATIVE] Invalid PaymentStatus (chk_inv_status; INSERT hits CHECK directly)
INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus)
VALUES ('INV_ST1', 'PAT001', TRUNC(SYSDATE), 500.00, 0.00, TRUNC(SYSDATE) + 3, 'Cancelled');
-- Expected: ORA-02290: check constraint (CHK_INV_STATUS) violated.

-- [62] student_5\04_invoice\positive\01_min_boundaries
-- Expected: 1 row inserted.
-- [POSITIVE - Min Boundaries] TotalAmount = 0.01, Discount = 0.00, InvoiceDate = 2020-01-01, DueDate = InvoiceDate
BEGIN
    SAVEPOINT sp_test;
    INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus)
    VALUES ('V1', 'PAT001', DATE '2020-01-01', 0.01, 0.00, DATE '2020-01-01', 'Overdue');
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
/

-- [63] student_5\04_invoice\positive\02_max_boundaries
-- Expected: 1 row inserted.
-- [POSITIVE - Max Boundaries] Discount = TotalAmount (100% discount), DueDate = InvoiceDate + 3
BEGIN
    SAVEPOINT sp_test;
    INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus)
    VALUES ('INV_MAX_01', 'PAT002', TRUNC(SYSDATE), 50000.00, 50000.00, TRUNC(SYSDATE) + 3, 'Unpaid');
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
/

-- [64] student_5\04_invoice\positive\03_defaults_and_nulls
-- Expected: 1 row inserted with defaults applied.
-- [POSITIVE - Defaults] Omit InvoiceDate (SYSDATE), Discount (0.00), DueDate (SYSDATE + 3), PaymentStatus ('Unpaid')
BEGIN
    SAVEPOINT sp_test;
    INSERT INTO Invoice (InvoiceID, PatientID, TotalAmount)
    VALUES ('INV_DEF_01', 'PAT003', 1500.00);
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
/

-- [65] student_5\04_invoice\positive\04_valid_update
-- Expected: 1 row updated.
-- [POSITIVE - Valid UPDATE] Update TotalAmount & Discount
BEGIN
    SAVEPOINT sp_test;
    UPDATE Invoice SET TotalAmount = 2000.00, Discount = 100.00 WHERE InvoiceID = 'INV001';
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
/

-- [66] student_5\05_payment\negative\01_duplicate_pk
-- [NEGATIVE] Duplicate PaymentID (pk_payment)
INSERT INTO Payment (PaymentID, InvoiceID, AmountPaid, PaymentMethod, TransactionReference)
VALUES ('PAY001', 'INV001', 100.00, 'Cash', 'TXN-DUP-PK-01');
-- Expected: ORA-00001: unique constraint (PK_PAYMENT) violated.

-- [67] student_5\05_payment\negative\02_invalid_payment_id
-- [NEGATIVE] Invalid PaymentID format (chk_pay_id)
INSERT INTO Payment (PaymentID, InvoiceID, AmountPaid, PaymentMethod, TransactionReference)
VALUES ('PAY@1', 'INV001', 100.00, 'Cash', 'TXN-BAD-ID-01');
-- Expected: ORA-02290: check constraint (CHK_PAY_ID) violated.

-- [68] student_5\05_payment\negative\03_invalid_invoice_fk
-- [NEGATIVE] Non-existent InvoiceID (fk_pay_invoice)
INSERT INTO Payment (PaymentID, InvoiceID, AmountPaid, PaymentMethod, TransactionReference)
VALUES ('PAY_FK1', 'INV999', 100.00, 'Cash', 'TXN-FK-01');
-- Expected: ORA-02291: integrity constraint (FK_PAY_INVOICE) violated.

-- [69] student_5\05_payment\negative\04_date_before_2020
-- [NEGATIVE] PaymentDate < 2020-01-01 (chk_pay_date_lower; non-existent INV999 lets trigger defer to CHECK)
INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference)
VALUES ('PAY_DT1', 'INV999', DATE '2019-12-31', 100.00, 'Cash', 'TXN-DT-01');
-- Expected: ORA-02290: check constraint (CHK_PAY_DATE_LOWER) violated.

-- [70] student_5\05_payment\negative\05_negative_amount_paid
-- [NEGATIVE] AmountPaid <= 0 (chk_pay_amt)
UPDATE Payment SET AmountPaid = -50 WHERE PaymentID = 'PAY001';
-- Expected: ORA-02290: check constraint (CHK_PAY_AMT) violated.

-- [71] student_5\05_payment\negative\06_invalid_payment_method
-- [NEGATIVE] Invalid PaymentMethod (chk_pay_method)
UPDATE Payment SET PaymentMethod = 'Crypto' WHERE PaymentID = 'PAY001';
-- Expected: ORA-02290: check constraint (CHK_PAY_METHOD) violated.

-- [72] student_5\05_payment\negative\07_duplicate_transaction_ref
-- [NEGATIVE] Duplicate TransactionReference (uq_pay_ref)
INSERT INTO Payment (PaymentID, InvoiceID, AmountPaid, PaymentMethod, TransactionReference)
VALUES ('PAY_REF1', 'INV001', 100.00, 'Cash', (SELECT TransactionReference FROM Payment WHERE PaymentID = 'PAY001'));
-- Expected: ORA-00001: unique constraint (UQ_PAY_REF) violated.

-- [73] student_5\05_payment\negative\08_invalid_transaction_ref_format
-- [NEGATIVE] TransactionReference < 4 chars or invalid chars (chk_pay_ref_fmt)
UPDATE Payment SET TransactionReference = 'TX' WHERE PaymentID = 'PAY001';
-- Expected: ORA-02290: check constraint (CHK_PAY_REF_FMT) violated.

-- [74] student_5\05_payment\negative\09_invalid_payment_status
-- [NEGATIVE] Invalid PaymentStatus (chk_pay_status)
UPDATE Payment SET PaymentStatus = 'Cancelled' WHERE PaymentID = 'PAY001';
-- Expected: ORA-02290: check constraint (CHK_PAY_STATUS) violated.

-- [75] student_5\05_payment\positive\01_min_boundaries
-- Expected: 1 row inserted.
-- [POSITIVE - Min Boundaries] AmountPaid = 0.01, PaymentDate = TRUNC(SYSDATE), 4-char TransactionReference
BEGIN
    SAVEPOINT sp_test;
    INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus)
    VALUES ('INV_PT1', 'PAT001', TRUNC(SYSDATE), 1000.00, 0.00, TRUNC(SYSDATE) + 3, 'Unpaid');
    INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus)
    VALUES ('Y1', 'INV_PT1', TRUNC(SYSDATE), 0.01, 'Cash', 'TX01', 'Completed');
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
/

-- [76] student_5\05_payment\positive\02_max_boundaries
-- Expected: 1 row inserted.
-- [POSITIVE - Max Boundaries] PaymentDate = TRUNC(SYSDATE), Bank Transfer
BEGIN
    SAVEPOINT sp_test;
    INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus)
    VALUES ('INV_PT2', 'PAT001', TRUNC(SYSDATE), 2000.00, 0.00, TRUNC(SYSDATE) + 3, 'Unpaid');
    INSERT INTO Payment (PaymentID, InvoiceID, PaymentDate, AmountPaid, PaymentMethod, TransactionReference, PaymentStatus)
    VALUES ('PAY_MAX_01', 'INV_PT2', TRUNC(SYSDATE), 1000.00, 'Bank Transfer', 'TXN-MAX-BOUNDARY-2026-001', 'Completed');
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
/

-- [77] student_5\05_payment\positive\03_defaults_and_nulls
-- Expected: 1 row inserted with defaults applied.
-- [POSITIVE - Defaults] Omit PaymentDate (SYSDATE) & PaymentStatus ('Completed')
BEGIN
    SAVEPOINT sp_test;
    INSERT INTO Invoice (InvoiceID, PatientID, InvoiceDate, TotalAmount, Discount, DueDate, PaymentStatus)
    VALUES ('INV_PT3', 'PAT001', TRUNC(SYSDATE), 2000.00, 0.00, TRUNC(SYSDATE) + 3, 'Unpaid');
    INSERT INTO Payment (PaymentID, InvoiceID, AmountPaid, PaymentMethod, TransactionReference)
    VALUES ('PAY_DEF_01', 'INV_PT3', 500.00, 'Debit Card', 'TXN-DEF-001');
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
/

-- [78] student_5\05_payment\positive\04_valid_update
-- Expected: 1 row updated.
-- [POSITIVE - Valid UPDATE] Update PaymentMethod & PaymentStatus
BEGIN
    SAVEPOINT sp_test;
    UPDATE Payment SET PaymentMethod = 'Credit Card', PaymentStatus = 'Refunded' WHERE PaymentID = 'PAY001';
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK TO sp_test;
END;
/
