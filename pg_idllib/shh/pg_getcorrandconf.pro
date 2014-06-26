;+
; NAME:
;
; pg_getcorrandconf
;
; PURPOSE:
;
; Get the cross correlation factor of two lightcurve as a fucntion of time,
; integrating over nint bins of the original lightcurve
;
; CATEGORY:
;
; time series util
;
; CALLING SEQUENCE:
;
; r=pg_getcorrandconf(xin,yin,nint=nint,sig=sig,rmin=rmin,rmax=rmax)
;
;
; INPUTS:
;
; xin,yin: the two time series to correlate 
;
; OPTIONAL INPUTS:
;
; nint: the number of bins for each correlation interval (default: 15)
; sig: confidence interval for the corr coefficient (default 95%)
;
; KEYWORD PARAMETERS:
;
; 
;
; OUTPUTS:
;
; r: correlation coefficients 
;
; OPTIONAL OUTPUTS:
;
; rmin,rmax: edges of the confidence interval
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
; 12-APR-2007 pg written
;-

;.comp pg_getcorrandconf

FUNCTION pg_getcorrandconf,xin,yin,nint=nint,sig=sig,rmin=rmin,rmax=rmax

  nint=fcheck(nint,15)
  sig=fcheck(sig,0.95);confidence interval

  oldnt=min([n_elements(xin),n_elements(yin)])
  
  newnt=oldnt/nint

  r=dblarr(newnt);correleation coeff
  rmin=r;sig conf interval
  rmax=r;

  FOR i=0,newnt-1 DO BEGIN
     
     x=xin[i*nint:(i+1)*nint-1]
     y=yin[i*nint:(i+1)*nint-1]
 
     res=pg_ccorr_conf(x,y,sig=sig)
     r[i]=res.r
     rmin[i]=res.rmin
     rmax[i]=res.rmax

ENDFOR

RETURN,r

END
