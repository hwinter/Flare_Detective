
; Nt=1001
; Nwave=1001

; wave=findgen(Nwave)/(Nwave-1)*100.+9.

; dw=100./(Nwave-1.)

; wave=transpose([[wave],[wave+dw]])

; edge_products,wave,mean=xen

; T=findgen(Nt)/(Nt-1)*100.+7.


; flux=1e5*mewe_kev(T,wave,/photon,/kev,/earth,/edges,/nol)


; ;mwrfits,flux,'~/work/spindex/fluxtemp.fits'
; flux=mrdfits('~/work/spindex/fluxtemp.fits',0,h)
; ;help,/mem
; i=100
; plot,xen,flux[i,*],/xlog,/ylog,yrange=[1e-10,1e10],xrange=[9,101],/xst

; for i=0,Nt-1 do $
; oplot,xen,flux[i,*];,/xlog,/ylog,yrange=[1e-10,1e10],xrange=[9,101],/xst



;fluxy=1e5*mewe_kev(10,wave,/photon,/kev,/earth,/edges,/nol)
;fluxx=f_vth(wave,[1,kel2kev(1e7)])

; lf=alog(flux)
; len=alog(xen)
; ;nmax=96

; ;nt=100
; ;nw=200

; slope=dblarr(nt,nwave-2)
; effen=dblarr(nwave-2)
; .run
; FOR i=0,nt-1 DO BEGIN
;     FOR j=0,nwave-3 DO BEGIN
;         slope[i,j]=-(lf[i,j+2]-lf[i,j+1])/(len[j+2]-len[j+1])
;         effen[j]=0.5*(xen[j+1]+xen[j+2])
;     ENDFOR
; ENDFOR
; end

;;;;;;;;;;;;;;;;;;;;;;

;mwrfits,slope,'~/work/spindex/slopetemp.fits'
;slope=mrdfits('~/work/spindex/fluxtemp.fits',0,h)


;check file ~/work/spindex/temp.pro
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
