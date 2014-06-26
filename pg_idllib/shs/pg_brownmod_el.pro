;+
; NAME:
;
; pg_brownmod_el
;
; PURPOSE:
;
; model for electron spectra from brown & loran...
;
; CATEGORY:
;
; shs project util, spex util
;
; CALLING SEQUENCE:
;
; 
;
; INPUTS:
;
; 
; 
; OUTPUTS:
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
; Paolo Grigis, Institute of Astronomy, ETH Zurich
; pgrigis@astro.pyhs.ethz.ch
; 
; MODIFICATION HISTORY:
;
; 01-JUL-2004 written P.G.
;
;-

FUNCTION pg_brownmod_el,B,alpha,alternative=alternative,inverse=inverse

IF keyword_set(inverse) THEN BEGIN

   delta=B

   IF alpha EQ 0. THEN $
     result=(delta+0.5)/sqrt(delta-1) $
     ELSE $
     result=(-1+sqrt(1+4*alpha*(delta+0.5)))/(2*alpha*sqrt(delta-1))

   return,result


ENDIF

IF NOT keyword_set(alternative) THEN BEGIN 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;B=A/sqrt(F)

b2=B*B
abb=alpha*b2

X=(1-abb)*(1-abb)
Y=2*(1-abb)*(0.5+abb)-b2
Z=(0.5+abb)*(0.5+abb)+b2

delta1=(-Y+sqrt(Y*Y-4*X*Z))/(2*X)
delta2=(-Y-sqrt(Y*Y-4*X*Z))/(2*X)

;both model ok!!!
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ENDIF ELSE BEGIN 


;B=A/sqrt(F)

b2=B*B
abb=alpha*b2

X=(1-abb)*(1-abb)
Y=3*(1-(alpha+1./3.)*b2)
Z=9./4.

delta1=1+(-Y+sqrt(Y*Y-4*X*Z))/(2*X)
delta2=1+(-Y-sqrt(Y*Y-4*X*Z))/(2*X)

;both model consistent!!!

ENDELSE

return,delta2


END
