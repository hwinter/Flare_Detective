;1: all OK
;0: not there
;-1: bogus time...



FUNCTION all_hessi_files_present,time_intv
out=1

filenames=hsi_filedb_filename(time_intv)
IF datatype(filenames) EQ 'INT' THEN RETURN,-1   ;this usually means a bogus time_intv ....
res=hsi_loc_file(filenames,/NO_DIALOG)
IF N_ELEMENTS(filenames) NE N_ELEMENTS(res) THEN out=0
RETURN,out
END
