;+
;
; NAME:
;        pg_getbeta
;
; PURPOSE: 
;        compute the relativistic beta factor from the relativistic
;        kinetic energy
;
; CALLING SEQUENCE:
;
;        beta=pg_getbeta(Ekin)
;
; INPUTS:
;
;        Ekin: kinetic energy, in units of mc^2
;
; OUTPUT:
;       beta: v/c
;        
; EXAMPLE:
;
;        
;
; VERSION:
;
;        20-OCT-2005 written PG
;        
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;-
FUNCTION pg_getbeta,ekin

   lambda=ekin*(ekin+2)
   RETURN,sqrt(lambda/(lambda+1))

END
