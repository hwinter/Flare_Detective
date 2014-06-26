;+
;
; NAME:
;        edge_transform
;
; PURPOSE: 
;        transform average values of an array in an array of bins
;
; CALLING SEQUENCE:
;
;        bin=edge_transform(average [,/invert] )
;
; INPUTS:
;
;        average: array[N] of energy values 
;
; OUTPUT:
;        bin: the bins
;
; KEYWORDS:
;        invert: transform from bins to array
;        
; EXAMPLE:
;
;        bin=edge_transform([3.5,4.5,5.5])
;        print,bin
;
; VERSION:
;
;        22-JUL-2003 written
;        
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;-

FUNCTION edge_transform,average,invert=invert

IF NOT keyword_set(invert) THEN BEGIN
    n=n_elements(average)

    intern_bins=dblarr(n+1)
    intern_bins[1:n-1]=(0.5*(average+shift(average,-1)))[0:n-2]
    intern_bins[0]=2*average[0]-intern_bins[1]
    intern_bins[n]=2*average[n-1]-intern_bins[n-1]    

    out_bins=transpose([[intern_bins[0:n-1]],[intern_bins[1:n]]])

    RETURN,out_bins

ENDIF $
ELSE BEGIN

    out_bins=transpose(0.5*(average[0,*]+average[1,*]))

    RETURN,out_bins
    
ENDELSE


END

