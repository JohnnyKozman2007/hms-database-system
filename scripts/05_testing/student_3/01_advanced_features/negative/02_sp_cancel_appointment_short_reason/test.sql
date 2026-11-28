-- [NEGATIVE] sp_cancel_appointment with Notes < 5 chars (chk_apt_notes_len)
-- Expected: ORA-02290: check constraint (CHK_APT_NOTES_LEN) violated.
BEGIN
    sp_cancel_appointment('APT001', 'No');
END;
/
