;+
; NAME:
;      pg_tauescvsdelta
;
; PROJECT:
;      diffusion & acceleration (plasma physics)
;
; PURPOSE: 
;      Return tau_escape as a function of delta (for details, see theory.tex)
;      
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
; KEYWORDS:
;
;
; HISTORY:
;       26-JUL-2005 written PG
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;
;-

FUNCTION pg_tauescvsdelta,delta,a_=a,b_=b,alpha=alpha,beta=beta,gamma=gamma,e1=e1,e0=e0

c=(a*(alpha-delta)*(alpha-delta-1)/(alpha+gamma-2*delta-1)* $
     (e1^(alpha+gamma-2*delta-1)-e0^(alpha+gamma-2*delta-1))- $
   2*b*(beta-delta)/(beta+gamma-2*delta)* $
      (e1^(beta+gamma-2*delta)-e0^(beta+gamma-2*delta)))* $
(2*gamma-2*delta+1)/(2*(e1^(2*gamma-2*delta+1)-e0^(2*gamma-2*delta+1)))


RETURN,c

END
