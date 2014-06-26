;+
; NAME:
;
; pg_adiabatic
;
; PURPOSE:
;
; adiabatic heating model from Maetzler et al. (ApJ 223,1058, 1978)
;
;
; CATEGORY:
;
; shs project util, spex util
;
; CALLING SEQUENCE:
;
; 
; INPUTS:
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
; 22-NOV-2004 written P.G.
;
;-

FUNCTION pg_adiabatic,e,EM,T

;e: energy array in kev >10 keV <100 keV
;T: temperature in keV
;EM: emission measure in cm^-3

;gaunt factor gff(E,T), from Eq.(2) of Maetzler et al. op.cit.
alpha=0.37*(30/T)^0.15
gff=0.9*(T/e)^alpha

;albedo correction
ind1=where(e LT 32.,count1)
ind2=where(e GE 32.,count2)

albedoR=dblarr(n_elements(e))

IF count1 GT 0 THEN BEGIN
   albedoR[ind1]=(0.21+0.31*(T/30.)^0.4)*alog(0.5+e[ind1]/14.3)
ENDIF
IF count2 GT 0 THEN BEGIN
   albedoR[ind2]=(0.31*(T/30.)^0.4-0.34*alog(e[ind2]/60.))> 0d
ENDIF

ctheta=1.4
albedoR=albedoR*ctheta

I=1.07d-42*EM/(e*sqrt(T))*gff*exp(-E/T)*(1+albedoR)

RETURN,I

END
