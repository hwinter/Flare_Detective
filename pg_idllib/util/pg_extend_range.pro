;+
; NAME:
;       pg_extend_range
;
; PURPOSE: 
;       
;       extends an input range (array of 2 floats or doubles)
;       by the minimum amount possible which still makes a difefrence
;       if the range is given in [max,min] it is reduced instead
;
; CALLING SEQUENCE:
;       res=pg_extend_range(range)
;
; INPUTS:
;       range: array 2 of floats or doubles
;
; OUTPUT:
;       the extende range
;
;
; HISTORY
;       written 01-SEP-2004
;       
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;-

FUNCTION pg_extend_range,range,safefactor=safefactor


safefactor=n_elements(safefactor) GT 0 ? safefactor: 1 

isdouble=size(range,/type) EQ 5

mach=machar(double=isdouble)

x=range[0]
y=range[1]

xeps=x GE 0 ? -mach.epsneg : mach.eps
yeps=y GE 0 ? mach.eps : -mach.epsneg


IF x EQ 0 THEN xres=-safefactor*mach.xmin ELSE xres=x*(1+safefactor*xeps)
IF y EQ 0 THEN yres=safefactor*mach.xmin  ELSE yres=y*(1+safefactor*yeps)

RETURN, [xres,yres]

END
