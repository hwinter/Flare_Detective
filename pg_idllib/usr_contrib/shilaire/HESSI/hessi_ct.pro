; by PSH , early 2001
;
;	MODIFIED 2001/11/02: more properly written
;	MODIFIED 2003/12/04: added keyword /QUICK (as suggested by P. Grigis), which assumes the location of the color file.
;

PRO hessi_ct,bw=bw, QUICK=QUICK

IF KEYWORD_SET(bw) THEN ct=42 ELSE ct=41

IF KEYWORD_SET(QUICK) THEN color_file = GETENV('SSW')+'/hessi/dbase/'+'colors_hessi.tbl' ELSE color_file = loc_file(path=hessi_data_paths(), 'colors_hessi.tbl')
LOADCT, file=color_file,ct
END
