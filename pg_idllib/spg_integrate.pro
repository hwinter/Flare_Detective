;+
;
; NAME:
;        spg_integrate
;
; PURPOSE: 
;        integrate a spectrogram
;
; CALLING SEQUENCE:
;
;        spg_out=spg_integrate(spg_in,xint=xint,yint=yint)
;
; INPUTS:
;        spg_in : a spectrogram
;
; OUTPUT:
;        
; EXAMPLE:
;
;        
;
; VERSION:
;
;          21-JUL-2003 written
;          23-JUL-2003 added espectrogram integration
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;-

FUNCTION spg_integrate,spg,xint=xint,yint=yint

IF NOT exist(xint) THEN xint=1
IF NOT exist(yint) THEN yint=1

nx=n_elements(spg.x)
ny=n_elements(spg.y)

newx=nx/round(xint)
newy=ny/round(yint)

xind=newx*xint-1
yind=newy*yint-1

spectrogram=rebin(spg.spectrogram[0:xind,0:yind],newx,newy)
x=rebin(spg.x[0:xind],newx)
y=rebin(spg.y[0:yind],newy)

IF tag_exist(spg,'ESPECTROGRAM') THEN BEGIN
    espectrogram=rebin(spg.espectrogram[0:xind,0:yind],newx,newy)
    spgrebinned={spectrogram:spectrogram,x:x,y:y,espectrogram:espectrogram}

ENDIF $
ELSE $
    spgrebinned={spectrogram:spectrogram,x:x,y:y}

spg_out=join_struct(spgrebinned,spg)

RETURN,spg_out

END












