;+
; NAME:
;
; pg_chi_linerrxy
;
; PURPOSE:
;
; returns chi squared for a linear function with errors in x and y as
; described in section 15.3 of numerical recipes in C, to be used by
; the function minimizer tnmin
;
; CATEGORY:
;
; linear regression, statistics
;
; CALLING SEQUENCE:
;
; chi=pg_chi_linerrxy(theta,xvec=xvec,yvec=yvec,xerr=xerr,yerr=yerr)
;
; INPUTS:
; 
; theta= arctan(slope)
; xvec,yvec,xerr,yerr: x,y,dx,dy data
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
; AUTHOR:
; 
; Paolo Grigis, Institute of Astronomy, ETH Zurich
; pgrigis@astro.phys.ethz.ch
;
; MODIFICATION HISTORY:
;
;-

FUNCTION pg_chi_linerrxy,theta,xvec=xvec,yvec=yvec,xerr=xerr,yerr=yerr

b=tan(theta);slope

w=1/(yerr^2+b^2*xerr^2);weights

a=total(w*(yvec-b*xvec))/total(w);intercept

chisq=total((yvec-a-b*xvec)^2/(yerr^2+b*b*xerr^2))


return,chisq

END

