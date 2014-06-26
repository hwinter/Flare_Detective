;+
; NAME:
;      nowrapshift
;
; PURPOSE: 
;      shift a vector without wrapping around (instead give 0) 
;
; CALLING SEQUENCE:
;      a=nowrapshift(a,i)
;
; INPUTS:
;      i: shifting index
;
; OUTPUT:
;             
;       
; RESTRICTIONS:
;      make sure that the absolute value of i is less than or equal
;      the vector size
;
; KEYWORDS:
;        
;
; HISTORY:
;       08-JAN-2003 written
;       
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;-

FUNCTION nowrapshift,a,i

dim=size(a)
s=dim[1]

IF i EQ 0 THEN RETURN,a

IF i GT 0 THEN BEGIN
    b=shift(a,i)
    b[0:i-1]=0
ENDIF $
ELSE BEGIN
    b=shift(a,i)
    b[dim[1]+i:dim[1]-1]=0
ENDELSE

RETURN,b
END

