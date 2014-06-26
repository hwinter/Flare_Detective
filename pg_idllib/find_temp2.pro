

;+
; NAME:
;      find_temp
;
; CALLING SEQUENCE:
;       temp=find_temp(e,s)
;
;
; PURPOSE: 
;      input a slope and an energy, find the temperature of a plasma
;      which would emit thermal bremsstrahlung radiation with the
;      given slope at the given energy 
;
; INPUTS:
;      e: the energy
;      s: the slope
;  
; OUTPUTS:
;      t: the temperature
;      
; KEYWORDS:
;        
;
; HISTORY:
;       25-JUN-2003 written
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;
;-


;useful range 10-100 keV for energy, 7-100 MK for temp

FUNCTION find_temp,e,s

slope=mrdfits('/global/saturn/data1/pgrigis/spindex/slopetemp.fits',0,h)
;flux=mrdfits('/global/saturn/data1/pgrigis/spindex/fluxtemp.fits',0,h)
Nt=1001
Nwave=1001

wave=findgen(Nwave)/(Nwave-1)*100.+9.

dw=100./(Nwave-1.)

wave=transpose([[wave],[wave+dw]])

edge_products,wave,mean=xen

effen=(0.5*(xen+shift(xen,-1)))[1:Nwave-2]


T=findgen(Nt)/(Nt-1)*100.+7.

a=min(abs(effen - e),index)

slopet=slope[*,index]

b=min(abs(slopet-s),index2)

RETURN,t[index2]

END
