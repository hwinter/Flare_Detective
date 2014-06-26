;+
; NAME:
;      pg_chandrag
;
; PROJECT:
;      numerical function evaluation
;
; PURPOSE: 
;      returns the value of the Chandrasekhar G function 
;
; EXPLICATION:
;      G(x) is defined as follows:  
;      
;      G(x)=(erf(x)-x*exp(-x^2))/(2*x^2)
;
;      however this scheme is numerically bad for x small
;      because of cancelletions in the subtraction,
;      therefore it is best to use
;
;      G(x)=igamma(1.5,x^2)/(2*x^2)
;
;      where igamma is the incomplete gamma function
;
;      igamma(t,x)=int_0^x exp(-y)*y^(t-1)dy / NORM
;
;      with NORM=int_0^infinity exp(-y)*y^(t-1)dy
;
;
;
; CALLING SEQUENCE:
;      y=pg_chandrag(x)
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
;       21-DEC-2006 written PG
;
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;
;-

;.comp pg_chandrag

FUNCTION pg_chandrag,x

;yerf=erf(x)
;RETURN,(yerf-2./sqrt(!DPi)*x*exp(-x*x))/(2*x*x)

return,igamma(1.5d,x*x)/(2*x*x)



END
