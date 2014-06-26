;+
; NAME:
;       hsi_imseq_get
;
; PURPOSE: 
;       retrieve an image sequence
;
; CALLING SEQUENCE:
;       hsi_imseq_get,filename
;
; INPUTS:
;        filename: base name of the fits file
;
; OUTPUT:
; 
;
; HISTORY:
;       27-JAN-2002 written, based on older material
;
; AUTHOR:
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;-

FUNCTION hsi_imseq_get,basefilename

N=0
WHILE file_exist(basefilename+strtrim(N,2)+'.dat') DO N=N+1
 
ptr=ptrarr(N > 1 )
 
FOR i=0,N-1 DO BEGIN
 
    filename=basefilename+strtrim(i,2)+'.dat'
    fits2map,filename,map,err=err
  
    IF err EQ '' THEN ptr[i]=ptr_new(map) $
    ELSE ptr[i]=ptr_new()
 
ENDFOR

RETURN,ptr

END

