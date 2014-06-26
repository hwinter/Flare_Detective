;+
; NAME:
;
; pg_refuniq
;
; PURPOSE:
;
; reform a linear array c to a rectangular one in such a way that the row and
; column index correspond to the uniquq elements of two arrays a and b
;
; CATEGORY:
;
; utilties (array manipulations)
;
; CALLING SEQUENCE:
;
; pg_refuniq,a_in,b_in,c_in,a_out=a_out,b_out=b_out,c_out=c_out
;
; INPUTS:
; 
; a_in,b_in: array with x and y coordinates for the elements of c
; c_in: array to be reformed
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
; a_out,b_out:sorted x,y coordinates
; c_out: the reformed array
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
; Paolo Grigis, Institute for Astronomy, ETH Zurich
; pgrigis@astro.phys.ethz.ch
;
; MODIFICATION HISTORY:
;
; 19-DEC-2005 written
;
;-

PRO pg_refuniq_test

a_in=[1,2,1,2,3,2,3,1,3]
b_in=[4,5,6,4,5,6,4,5,6]
c_in=[0,1,2,3,4,5,6,7,8]

;pg_refuniq,a_in,b_in,c_in,a_out=a_out,b_out=b_out,c_out=c_out

print,c_out


END


PRO pg_refuniq,a_in,b_in,c_in,a_out=a_out,b_out=b_out,c_out=c_out

asort=sort(a_in)
bsort=sort(b_in)

auniq=uniq(a_in[asort])
buniq=uniq(b_in[bsort])

ael=n_elements(auniq)
bel=n_elements(buniq)
cel=n_elements(c_in)

IF cel NE ael*bel THEN BEGIN
   print,'INVALID INPUT!'
   stop
   RETURN
ENDIF

a_out=a_in[asort[auniq]]
b_out=b_in[bsort[buniq]]

c_out=reform(c_in,ael,bel)

listind=bsort[lindgen(buniq[0]+1)]
c_out[*,0]=c_in[listind]

FOR i=1,bel-1 DO BEGIN 
   listind=bsort[lindgen(buniq[i]-buniq[i-1])+buniq[i-1]+1]
   ;aunsorted=a_in[listind]
   ;putintoc=sort(aunsorted)
   c_out[*,i]=c_in[listind]
ENDFOR

RETURN

   
END
