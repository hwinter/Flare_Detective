;+
; NAME:
;      pg_elsp2photsp
;
; PURPOSE: 
;      Transform an input electron spectrum flux (el. s^-1 cm^-2 keV^-1) given
;      as an array of values for a discrete set of energies into an
;      emitted photon spectrum in units of photons s^-1 cm^-3 keV^-1 
;      This correspond to the so-called "thin-target" emission.
;
; CALLING SEQUENCE:
;      photsp=pg_elsp2photsp(elsp=elsp,ele=ele,phe=phe [optional keywords?])
;
; INPUTS:
;      elsp: array of N elements with the electron spectrum
;      ele:  array of N elements with the elctron energies
;      phe:  array of M elements with the desired photon energies
;
; KEYWORDS:
;      
;
; OUTPUT:
;      photsp: photon spectrum at nergies eph
;       
;
; COMMENT:
;
;
; EXAMPLE   
;
;
;
; VERSION:
;       17-OCT-2005 written PG
;       
; AUTHOR:
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;-

PRO test_pg_elsp2photsp

;.comp pg_elsp2photsp

N=1000
ele=10^(dindgen(N)/(N-1)*4)
elsp=1d10*ele^(-3)

M=100
phe=10^(1+dindgen(M)/(M-1)*2)



res=pg_elsp2photsp(elsp=elsp,ele=ele,phe=phe)

lf1=linfit(alog(ele),alog(elsp))
lf2=linfit(alog(phe),alog(res))

print,exp(lf1[0])/exp(lf2[0])


linecolors

plot,ele,elsp,/xlog,/ylog,thick=3
oplot,phe,res,thick=3

oplot,ele,exp(lf1[0])*ele^(lf1[1]),color=12
oplot,ele,exp(lf2[0])*ele^(lf2[1]),color=12


END


FUNCTION pg_elsp2photsp,elsp=elsp,ele=ele,phe=phe,cross_section=cross_section


;mc2=510.99892d
;c=29979245800d
;elspeed=sqrt(1d -1d /(1+ele/mc2)^2)*c
;elspflux=elsp*sqrt(ele);*elspeed

elspflux=elsp

nph=n_elements(phe)
photsp=dblarr(nph)

IF max(phe) GE 0.5*max(ele) THEN BEGIN 
   print,'To get meaningful results out of this routine one should'
   print,'have that the max electron energy is larger than at least'
   print,'twice the max photon energy!'
   RETURN,-1
ENDIF

brem_cross='pg_brem_red_crosssec'

xin=ele
yin=elspflux/ele*call_function(brem_cross,phe[0],ele);,/kramers)
plot,xin,yin,/xlog,/ylog
oplot,phe,pg_interpolate(phe,xin=xin,yin=yin),color=12

FOR i=0,nph-1 DO BEGIN 
   xin=ele
   yin=elspflux/ele*call_function(brem_cross,phe[i],ele);,/kramers)
   IF (i MOD 10) EQ 0 THEN BEGIN 
   oplot,xin,yin
   oplot,phe,pg_interpolate(phe,xin=xin,yin=yin),color=12
   ENDIF
   photsp[i]=1d /phe[i]*qpint1d('pg_interpolate',phe[i],max(ele),functargs={xin:xin,yin:yin})
   ;photsp[i]=1d /phe[i]*qpint1d('identity',phe[i],max(ele));,functargs={xin:xin,yin:yin})

ENDFOR 


RETURN,photsp

END
