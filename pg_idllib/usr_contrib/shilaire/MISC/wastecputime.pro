
;PRO wastecputime
;	i=1	
;	WHILE i EQ 1 DO BEGIN
;		j=1234.56 * 12345.67
;		PRINT,j
;	ENDWHILE
FOR i=0L, 100000 DO BEGIN
	PRINT,i
ENDFOR
;EXIT
END




;TO run from IDL session :
;cmd='idl /global/carme/home/shilaire/IDL/MISC/wastecputime &'
;SPAWN,cmd
