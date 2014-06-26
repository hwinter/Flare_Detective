;+
; NAME:
;
; pg_log2lin
;
; PURPOSE:
;
; from measured distances in a logarithmic scale, gives the linear
; value
;
;     |-------X----------------|
;   xref1                    xref2
;     <------------------------> deltaref
;     <-------> deltax
;
;
; CATEGORY:
;
; various utilities
;
; CALLING SEQUENCE:
;
; linvalue=pg_log2lin,xref1,xref2,deltaref,deltax
;
; INPUTS:
;
; xref1: first reference value
; xref2: second reference value
; deltaref: physical distance between xref1 and xref2
; deltax: physical distance between xref1 and the meaured point
;
; OUTPUTS:
;
; linvalue: x coordinate of the measured point
;
; METHOD: uses the formula: linvalue=xref1*(xref2/xref1)^(deltax/deltaref)
;
; EXAMPLE:
;
; print,pg_log2lin(1.,100.,2.5,1.25)
; 
;
; AUTHOR:
;
; Paolo Grigis, Institute of Astronomy, ETH Zurich
; pgrigis@astro.phys.ethz.ch
;
; MODIFICATION HISTORY:
;
; 26-JAN-2003 written
;
;-

FUNCTION pg_log2lin,xref1,xref2,deltaref,deltax

linvalue=xref1*(xref2/xref1)^(deltax/deltaref)

RETURN,linvalue    


END
