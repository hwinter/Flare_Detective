;+
; NAME:
;      vect_convolve
;
; PURPOSE: 
;      convolution of two vectors of the same size
;
; CALLING SEQUENCE:
;      ans=vect_convolve(a,b)
;
; INPUTS:
;      a,b: two vectors
;
; OUTPUT:
;             
;       
; RESTRICTIONS:
;      a,b should have the same size
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

FUNCTION vect_convolve,x,a,b

dim=size(a)
s=dim[1]

ans=dblarr(s)

FOR i=0,s-1 DO BEGIN
    ;ans[s-1-i]=int_tabulated(x,a*nowrapshift(b,s/2-i))
    ans[s-1-i]=int_tabulated(x,a*nowrapshift(b,s/2-i))

    ;nowrapshift(b,s/2-i))
    ;ans[i]=int_tabulated(x,a*nowrapshift(b,(s/2+i) mod s))
    ;ans[i]=int_tabulated(x,a*nowrapshift(b,s/2-i))
ENDFOR

RETURN,ans

END

