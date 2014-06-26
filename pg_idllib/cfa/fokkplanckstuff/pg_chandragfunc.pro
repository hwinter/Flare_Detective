;+
; NAME:
;
; PG_CHANDRAGFUNC
;
; PURPOSE:
;
; Returns the so-called Chandrasekhar G-function
;
; CATEGORY:
;
; Plasma kinetics utils
;
; CALLING SEQUENCE:
;
; y=pg_chandragfunc(x)
;
; INPUTS:
;
; x: real arcument
;
; OPTIONAL INPUTS:
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
; See: Collisional Transport in Magnetized Plasmas. Helander & Sigmar, CUP 2002
;
; EXAMPLE:
;
;
; AUTHOR:
;
; Paolo Grigis
; pgrigis@cfa.harvard.edu
;
; MODIFICATION HISTORY:
;
; 17-DEC-2008 PG written
;
;-

FUNCTION pg_chandragfunc,x

piinv=2d/sqrt(!Dpi)

RETURN,(erf(x)-piinv*x*exp(-x*x))/(2*x*x)

END


