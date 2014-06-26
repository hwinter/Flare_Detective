;+
; NAME:
;       pg_apar2flux_fmultispec
;
; PURPOSE: 
;       convert a structure from spex to nonthermal flux at an energy e
;
; CALLING SEQUENCE:
;       out=pg_apar2flux_fmultispec(sp_st,en)
;
; INPUTS:
;
;       sp_st: usual structure from spex, must contain at least
;       apar_arr, apar_del if errors are desired, epivot (otherwise
;       default 50 is taken)
;       en: reference energy
;
; OUTPUTS:
;
;       out: {flux:flux,eflux:eflux,energy:energy}
;       
; KEYWORDS:
;       
;
; EXAMPLE:
;       
;
; VERSION:
;       
; HISTORY:
;       15-SEP-2003 written
;       19-NOV-2003 adapted for use with f_multi_spec, accept
;       spex_structure as input, computes errors
;       26-FEB-2004 corrected a bug which caused incorrect results
;       if en was an integer
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;-

FUNCTION pg_apar2flux_fmultispec,sp_st,en,no_errors=no_errors

e=float(fcheck(en,35.))

apar_arr=sp_st.apar_arr
nint=(size(apar_arr))[2]

IF tag_exist(sp_st,'epivot') THEN epiv=sp_st.epivot ELSE epiv=50.
;epiv=replicate(epiv,nint)   

dmin=apar_arr[5,*]; power law index below break
dmag=apar_arr[7,*]; power law index above break
dcut=apar_arr[9,*]; power law index above break
ebr=apar_arr[6,*]; break energy
ecut=apar_arr[8,*]; cutoff energy
fpiv=apar_arr[4,*];flux at epiv

IF NOT keyword_set(no_errors) THEN BEGIN
apar_sigma=sp_st.apar_sigma

edmin=apar_sigma[5,*]; power law index below break err
edmag=apar_sigma[7,*]; power law index above break err
edcut=apar_sigma[9,*]; power law index above break err
eebr=apar_sigma[6,*]; break energy err
eecut=apar_sigma[8,*]; cutoff energy err
efpiv=apar_sigma[4,*];flux at epiv err
ENDIF

low=where(e LT ecut,countlow) 
high=where(e GT ebr,counthigh)
norm=where((e GE ecut) AND (e LT ebr),countnorm)

flux=fpiv

IF countlow GT 0 THEN flux[low]=(fpiv*(epiv/ecut)^dmin*(ecut/e)^dcut)[low]
IF counthigh GT 0 THEN flux[high]=(fpiv*(epiv/ebr)^dmin*(ebr/e)^dmag)[high]
IF countnorm GT 0 THEN flux[norm]=(fpiv*(epiv/e)^dmin)[norm]
 
out_str={flux:reform(flux),energy:e}

IF NOT keyword_set(no_errors) THEN BEGIN
eflux=flux

IF countlow GT 0 THEN $
  eflux[low]=(flux*sqrt((efpiv/fpiv)^2+alog(epiv/ecut)^2*edmin^2 $
                         +alog(ecut/e)^2*edcut^2 $
                         +((dcut-dmin)/ecut)^2*eecut^2))[low]

IF counthigh GT 0 THEN $
  eflux[high]=(flux*sqrt((efpiv/fpiv)^2+alog(epiv/ebr)^2*edmin^2 $
                         +alog(ebr/e)^2*edmag^2 $
                         +((dmag-dmin)/ebr)^2*eebr^2))[high]
IF countnorm GT 0 THEN $
  eflux[norm]=(flux*sqrt((efpiv/fpiv)^2+alog(epiv/e)^2*edmin^2))[norm]

out_str={flux:reform(flux),eflux:reform(eflux),energy:e}

ENDIF

RETURN,out_str

END






