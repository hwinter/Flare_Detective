;+
; NAME:
;
; pg_modfit
;
; PURPOSE:
;
; spectral model for fitting data, in format suitable for using with mpfitfun...
;
; CATEGORY:
;
; rhessi spectrograms/fitting util
;
; CALLING SEQUENCE:
;
; result=pg_modfit(e)
;
; INPUTS:
;
; 
;
; OPTIONAL INPUTS:
;
;
;
; KEYWORD PARAMETERS:
;
; 
;
; OUTPUTS:
;
; 
;
; OPTIONAL OUTPUTS:
;
;
;
; COMMON BLOCKS:
;
;
;
; SIDE EFFECTS:
;
;
;
; RESTRICTIONS:
;
;
;
; PROCEDURE:
;
;
;
; EXAMPLE:
;
;
;
; AUTHOR:
; Paolo Grigis, Institute for Astronomy, ETH Zurich
; pgrigis@astro.phys.ethz.ch 
;
; MODIFICATION HISTORY:
;
; 06-NOV-2006 pg written
;-

;.comp pg_modfit

FUNCTION pg_parabmod,dummy,par,photedges=photedges,enorm=enorm $
                  ,drm=drm,geom_area=geom_area,cntrange=cntrange $
                  ,photonout=photonout,background=background


  ;default values
  geom_area=fcheck(geom_area,1.)
  enorm=fcheck(enorm,50.)
  cntrange=fcheck(cntrange,lindgen(n_elements(drm[*,0])))
  background=fcheck(background,0.)

  ;energy binning size
  de=photedges[*,1]-photedges[*,0]
  ;mean value of energy in bin
  logavge=sqrt(photedges[*,1]*photedges[*,0])

  ;fit parameters
  a=par[0];ln(y)=a*ln(x)^2+b*ln(x)+ln(c)
  b=par[1];
  c=par[2];
  
;  indh=where(logavge GE ebreakh,counth)
;  indl=where(logavge LE ebreakl,countl)
;  ind=where(logavge GE ebreakl AND logavge LE ebreakh,count)

  photonout=logavge*0.


  photonout=exp(a*alog(logavge/enorm)^2+b*alog(logavge/enorm))*c

;  IF count GT 0 THEN  photonout[ind]=fnorm*(logavge[ind]/enorm)^(-d)

;  IF counth GT 0 THEN $
;     photonout[indh]=fnorm*(ebreakh/enorm)^(-d)*(logavge[indh]/ebreakh)^(-dh) ;photons cm^-2 kev^-1 sec^-1
;  IF countl GT 0 THEN $
;     photonout[indl]=fnorm*(ebreakl/enorm)^(-d)*(logavge[indl]/ebreakl)^(-dl) ;photons cm^-2 kev^-1 sec^-1


  ;continuum thermal component
  em=par[3]
  temp=par[4]

  IF temp GT 0 THEN BEGIN 
  ;therm=f_vth(logavge,[em,temp],/continuum,/mewe);photons cm^-2 kev^-1 sec^-1
     photonout=photonout+1d5*em*mewe_kev(kev2kel(temp)*1d-6,transpose(photedges) $
                                         ,/photon,/kev,/earth,/edges,/noline) 
  ENDIF 

  
  ;plot,logavge,therm,/xlog,/ylog
  ;oplot,logavge,result,color=12
  ;plot,logavge,therm/result,/xlog


  ;model spectrum, in units photons cm^-2 sec^-1 
  yy=photonout*de

  ;IF exist(background) THEN BEGIN  
  y=drm#yy*geom_area            ;+background ;count spectrum from model in 
     ;in units of counts s^-1 cm^-2 keV^-1 * geom_area = counts s^-1 keV^-1
  ;ENDIF ELSE BEGIN
  ;   y=drm#yy*geom_area ;count spectrum from model in 
     ;in units of counts s^-1 cm^-2 keV^-1 * geom_area = counts s^-1 keV^-1
  ;ENDELSE

  y=y+par[5]*background


  return,y[cntrange]


END