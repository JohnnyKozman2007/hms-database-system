-- [NEGATIVE] fn_get_patient_net_balance with non-existent PatientID
SELECT fn_get_patient_net_balance('PAT999') FROM DUAL;
-- Expected: ORA-20040: Patient ID PAT999 does not exist.
