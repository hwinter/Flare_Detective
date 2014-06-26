;+
;
; NAME:
;        spfit
;
; PURPOSE: 
;        fits a spectrum, + some utilities (tbd)
;
; CALLING SEQUENCE:
;
;        par=spfit,en,sp,esp
;
; INPUTS:
;
;        en:energies vector
;        sp:spectrum
;        esp:error in spectrum
;
; OUTPUT:
;        par: fit pars
;
; KEYWORDS:
;        
;        
; EXAMPLE:
;
; 
;
; VERSION:
;
;        20-AUG-2003 written
;        
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;-

FUNCTION spfit,en,sp,esp,startpar=startpar,parinfo=parinfo $
              ,energyrange=energyrange

en2=en
sp2=sp
esp2=esp

IF exist(energyrange) THEN BEGIN
    energyrange=energyrange(sort(energyrange))
    index=where(en GE energyrange[0] AND en LE energyrange[1],count)
    IF count GT 0 THEN BEGIN
        en2=en[index]
        sp2=sp[index]
        esp2=esp[index]
    ENDIF $
    ELSE $
        RETURN, 0.

ENDIF

IF NOT exist(startpar) THEN startpar=[1e-2,1.5,1e5,4,1,1,50,4]

IF NOT exist(parinfo) THEN BEGIN

    parinfo=replicate({value:0.D, fixed:0, limited:[0,0], $
                       limits:[0.D,0]}, 8)
    parinfo[*].value=startpar
    ;parinfo[4:5].fixed=1.
    ;parinfo[7].fixed=1.
    parinfo[0:3].limited=[1,1]
    parinfo[6].limited=[1,1]
    parinfo[0].limits=[0d,1d4]
    parinfo[1].limits=[0.5,20.]
    parinfo[2].limits=[0.d,1d+30]
    parinfo[3].limits=[1.5,12]
    parinfo[6].limits=[15,200]

ENDIF

ind=where(sp2 LE 0.,count)
IF count GT 0 THEN BEGIN
    sp2[ind]=max(sp2)
    sp2[ind]=min(sp2)
ENDIF

ind=where(esp2 LE 0.,count)
IF count GT 0 THEN BEGIN
    esp2[ind]=max(esp2)
    esp2[ind]=min(esp2)
ENDIF

functargs={noline:1,log:1}
par=mpfitfun('thermal_tpow',en2,alog(sp2),esp2/sp2,parinfo=parinfo $
            ,functargs=functargs)
 

RETURN,par

END

