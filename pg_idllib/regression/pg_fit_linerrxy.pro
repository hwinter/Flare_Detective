;+
; NAME:
;
; pg_fit_linerrxy
;
; PURPOSE:
;
; fit a linear trend to data with errors in both x and y
;
; CATEGORY:
;
; linear regression, statistics
;
; CALLING SEQUENCE:
;
; out=pg_chi_linerrxy(x,y,xerr,yerr,est_slope=est_slope)
;
; INPUTS:
; 
; x,y,xerr,yerr: data and errors
;
; OPTIONAL INPUTS:
;
; est_slope: estimate of the slope
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
; AUTHOR:
; 
; Paolo Grigis, Institute of Astronomy, ETH Zurich
; pgrigis@astro.phys.ethz.ch
;
; MODIFICATION HISTORY:
;
; 04-03-2004 written
;
;-

FUNCTION pg_fit_linerrxy,x,y,xerr,yerr,est_slope=est_slope

est_slope=fcheck(est_slope,(linfit(x,y))[1])

theta_parinfo={value:atan(est_slope),fixed:0,limited:[1,1] $
             ,limits:[-!dpi/2d,!dpi/2d]}
functargs={xvec:x,yvec:y,xerr:xerr,yerr:yerr}

theta=tnmin('pg_chi_linerrxy',parinfo=theta_parinfo,/autoderivative $
           ,functargs=functargs)

b=tan(theta);slope
w=1/(yerr^2+b^2*xerr^2);weights
a=total(w*(y-b*x))/total(w);intercept

return,[a,b]

END


