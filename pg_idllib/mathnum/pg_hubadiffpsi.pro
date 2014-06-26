;+
; NAME:
;      pg_hubadiffpsi
;
; PROJECT:
;      numerical function evaluation
;
; PURPOSE: 
;      returns the value of the derivative of the PSI function as used in HUBA NRL
;      plasma formulary
;
; EXPLICATION:
;      PSI is defined by Huba as follows:  
;      
;      psi(x)=2/sqrt(Pi)*int_0^x (sqrt(t)*exp(-t) dt)
;
;      which can be transformed into
;
;      psi(x)=erf(sqrt(x))-2/sqrt(Pi)*sqrt9x)*exp(-x)
;
;      The derivative is
;
;      diffpsi(x)=2/sqrt(Pi)*sqrt(x)*exp(-x)
;
;
;
; CALLING SEQUENCE:
;      y=pg_hubadiffpsi(x)
;
; INPUTS:
;      x: an array of arguments (should be 0 or positive for
;         meaningful output)
;   
; OUTPUTS:
;      y: an array of values
;      
; KEYWORDS:
;
;
; HISTORY:
;       04-MAY-2005 written PG
;       17-JUN-2005 corrected normalization factor (was wrong by a
;                   factor sqrt(!Pi))
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;
;-

FUNCTION pg_hubadiffpsi,x

y=2/sqrt(!Pi)*sqrt(x)*exp(-x)

RETURN,y

END
