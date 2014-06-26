;	Pascal Saint-Hilaire	2001/09/06
;	shilaire@astro.phys.ethz.ch OR psainth@hotmail.com

; this simple routines just returns a directory path with a slash 
;	(or backslash for windows).

FUNCTION dir_slash, dir
slash= '/'
IF !VERSION.OS_FAMILY EQ 'Windows' THEN slash = '\'
IF STRMID(dir,STRLEN(dir)-1,1) NE slash THEN dir = dir + slash
return, dir
END
