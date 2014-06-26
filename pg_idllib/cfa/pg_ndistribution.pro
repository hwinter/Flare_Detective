;+
; NAME:
;
; pg_nidstribution
;
; PURPOSE:
;
;
;
; CATEGORY:
;
;
;
; CALLING SEQUENCE:
;
;
;
; INPUTS:
;
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
; MODIFICATION HISTORY:
;
;-

FUNCTION pg_ndistribution,energy,temp=temp,nfactor=nfactor,k=k

nfactor=fcheck(nfactor,1.0)
temp=fcheck(temp,10.0);MK
print,temp
k=fcheck(k,0.086);keV/MK
Bn=1.0/(2*gamma(0.5*nfactor+1))
ndistro=Bn*2*energy^(0.5*nfactor)*(k*temp)^(-0.5*nfactor-1)*exp(-energy/(k*temp))

return,ndistro

END 
