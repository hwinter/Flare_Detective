;+
; NAME:
;      hsi_load_imseq
;
; PURPOSE: 
;      restore an images sequence, given the base filename 
;
; INPUTS:
;      basefilename: the base file name
;  
; OUTPUTS:
;      ptr: array of pointer to map
;      
; KEYWORDS:
;        
;
; HISTORY:
;       23-JAN-2002 written
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;
;-

FUNCTION hsi_load_imseq,basefilename

print,'Obsolete routine, please use hsi_imseq_get'
RETURN,-1

; N=0
; WHILE file_exist(basefilename+strtrim(N,2)+'.dat') DO N=N+1
 
; ptr=ptrarr(N)
 
; FOR i=0,N-1 DO BEGIN
 
;     filename=basefilename+strtrim(i,2)+'.dat'
;     fits2map,filename,map,err=err
 
;     IF err EQ '' THEN ptr[i]=ptr_new(map) $
;     ELSE ptr[i]=ptr_new()
 
; ENDFOR

; RETURN,ptr 

END











