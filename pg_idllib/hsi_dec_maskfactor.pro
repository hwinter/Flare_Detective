;+
; NAME:
;       hsi_dec_maskfactor
;
; PURPOSE: 
;       produces a correction factor for decimation, given the dec
;       energy and the energy binning, such that
;       corrected flux = old flux * correction factor
;
; CALLING SEQUENCE:
;       corr_factor=hsi_dec_maskfactor(energy,binning,weight)
;
; INPUTS:
;
;       energy: the dec energy      
;       binning: energy binning to which the factor should apply
;       weigth: decimation weight
;
; OUTPUTS:
;
;       corr_factor: correction factor
;       
; KEYWORDS:
;       
;
; EXAMPLE:
;       energy=10.
;       binning=[5.,7,9,11,13,15]
;       weight=1.
;       corr_fact=hsi_dec_maskfactor(energy,binning,weight)
;
; VERSION
;       
; HISTORY
;       25-JUN-2003 in writing
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich

;-

FUNCTION hsi_dec_maskfactor,energy,binning,weight

;convert binning to edges_2 style 
edge_products,binning,edges_2=ebin ;array ebin is 2xn

n=(size(ebin))[2]
corr_fact=replicate(1d,n)



; these are fully decimated
wh_totdec=where(ebin[1,*] LE energy,count)

IF count GE 1 THEN BEGIN
    corr_fact[wh_totdec]=weight+1
ENDIF



;these are only partial decimated in energy binning
wh_pardec=where( (ebin[1,*] GT energy) AND (ebin[0,*] LT energy),count)

FOR i=0,count-1 DO BEGIN
    a=ebin[0,wh_pardec[i]]
    c=ebin[1,wh_pardec[i]]
    b=energy

    ;for the correction factor we assume a constant flux over the bin
    corr_fact[wh_pardec[i]]=(c-a) / ( c-b + (b-a)/double(weight+1))
    
ENDFOR



RETURN,corr_fact


END

