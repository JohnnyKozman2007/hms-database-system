-- [NEGATIVE] Future Admission.AdmissionDate (trg_adm_date_max)
UPDATE Admission SET AdmissionDate = SYSDATE + 3 WHERE AdmissionID = 'ADM001';
-- Expected: ORA-20001: Admission.AdmissionDate cannot be in the future (exceeds SYSDATE).
