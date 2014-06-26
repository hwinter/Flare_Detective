;+
;
; NAME:
;        pg_getsimparvalues
;
; PURPOSE: 
;        get a value from a name in simpar structure
;
; CALLING SEQUENCE:
;
;        
;
; INPUTS:
;
;        
;
; KEYWORDS:
;
;        
;
; OUTPUT:
;        
;
; EXAMPLE:
;
;        
;
; VERSION:
;
;        16-NOV-2005 written PG        
;        
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;       pgrigis@astro.phys.ethz.ch
;-

FUNCTION pg_getsimparvalue,simpar,namelist,err=err

err=0

n=n_elements(namelist)
parval=simpar.parvalues
parnam=simpar.parnames

outval=dblarr(n)

FOR i=0,n-1 DO BEGIN 

   ind=where(parnam EQ namelist[i],count)

   IF count NE 1 THEN BEGIN
      err=1
      RETURN,-1
   ENDIF

   outval[i]=parval[ind]
   
ENDFOR

IF n EQ 1 THEN RETURN,outval[0] ELSE RETURN,outval

END
