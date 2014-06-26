;+
;
; NAME:
;        pg_getsimpar
;
; PURPOSE: 
;        return the value(s) of a simulation parameter(s)
;
; CALLING SEQUENCE:
;
;        ans=pg_getsimpar(da,names)
;
; INPUTS:
;
;        da: simulation output, a structure
;        names: an array of paramter names
;
; OUTPUT:
;        
; EXAMPLE:
;
;        
;
; VERSION:
;
;        14-NOV-2005 written PG
;        
;
; AUTHOR
;       pgrigis@astro.phys.ethz.ch
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;-

FUNCTION pg_getsimpar,da,names

n=n_elements(names)
res=dblarr(n)

FOR i=0,n-1 DO BEGIN 

   ind=where(da.simpar.parnames EQ names[i],count)

   IF count NE 1 THEN BEGIN 
      print,'A problem has occurred in "pg_getsimpar.pro"'
      return,-1
   ENDIF

   res[i]=da.simpar.parvalues[ind]

ENDFOR

IF n EQ 1 THEN res=res[0]

RETURN,res

END












