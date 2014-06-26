;+
; NAME:
;      hsi_spg_reduce
;
; PURPOSE: 
;      return a selected part of a larger spectrogram 
;
; INPUTS:
;      spg: original spectrogram
;      timerange: the selected timerange
;      erange: the selected energy range
;  
; OUTPUTS:
;      returns the reduced spg
;      
; KEYWORDS:
;        
;
; HISTORY:
;       9-OCT-2002 written
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;
;-

FUNCTION hsi_spg_reduce,timerange=timerange,erange=erange,spg=spg

IF n_elements(erange) NE 2 THEN erange=[min(spg.y),max(spg.y)] $
ELSE erange=erange[sort(erange)]
IF n_elements(timerange) NE 2 THEN timerange=[min(spg.x),max(spg.x)] $
ELSE timerange=timerange[sort(anytim(timerange))]
timerange=anytim(timerange)

qy=where(spg.y GE erange[0] AND spg.y LE erange[1])
qx=where(spg.x GE timerange[0] AND spg.x LE timerange[1])

xx=spg.x[qx]
yy=spg.y[qy]

tmp=spg.spectrogram
sspg=dblarr(n_elements(xx),n_elements(yy))

FOR i=0L,n_elements(xx)-1 DO FOR j=0L,n_elements(yy)-1 DO $
sspg[i,j]=tmp[qx[i],qy[j]]

spg2={x:xx,y:yy,spectrogram:sspg}
RETURN,spg2

END











