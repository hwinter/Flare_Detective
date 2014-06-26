;+
; NAME:
;
; pg_arrmaxpos
;
; PURPOSE:
;
; prints the value and the position of the maximum of an array
;
; CATEGORY:
;
; data manip utils
;
; CALLING SEQUENCE:
;
; pg_arrmaxpos,a
;
; INPUTS:
;
; a: any numeric array
; 
;
; OPTIONAL INPUTS:
;
;
;
; KEYWORD PARAMETERS:
;
;
;
; OUTPUTS:
;
;
;
; OPTIONAL OUTPUTS:
;
;
;
; COMMON BLOCKS:
;
;
;
; SIDE EFFECTS:
;
;
;
; RESTRICTIONS:
;
;
;
; PROCEDURE:
;
;
;
; EXAMPLE:
;
;
;
; AUTHOR:
;
; Paolo Grigis, CfA
; pgrigis@cfa.haravrd.edu
;
; MODIFICATION HISTORY:
;
; 4-MAR-2009 written PG 
;
;-

PRO  pg_arrmaxpos,a,format=format

maxvalue=max(a)
ind=where(a EQ maxvalue)

indarr=array_indices(a,ind)

string='MAX: '+strtrim(string(maxvalue,format=format),2)+' '

FOR i=0,n_elements(indarr)-1 DO BEGIN 
   string+=' DIM'+strtrim(i,2)+' : '+strtrim(indarr[i],2)
ENDFOR

print,string

END


