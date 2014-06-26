;+
; NAME:
;
; pg_modfitdualtherm
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
; 13-NOV-2006 pg written
;-

;.comp pg_modfitdualtherm

FUNCTION pg_modfitdualtherm,dummy,par,photedges=photedges,enorm=enorm $
                  ,drm=drm,geom_area=geom_area,cntrange=cntrange $
                  ,photonout=photonout,background=background


  ;default values
  enorm=fcheck(enorm,35)
  geom_area=fcheck(geom_area,1.)
  cntrange=fcheck(cntrange,lindgen(n_elements(drm[*,0])))
  background=fcheck(background,0.)

  ;energy binning size
  de=photedges[*,1]-photedges[*,0]
  ;mean value of energy in bin
  logavge=sqrt(photedges[*,1]*photedges[*,0])

  ;fit parameters
  ;continuum thermal component
  emlow=par[0]
  templow=par[1]
  emhigh=par[2]
  temphigh=par[3]

  IF (templow GT 0) AND (temphigh GT 0) THEN BEGIN 
  ;therm=f_vth(logavge,[em,temp],/continuum,/mewe);photons cm^-2 kev^-1 sec^-1
     photonout=1d5*emlow*mewe_kev(kev2kel(templow)*1d-6,transpose(photedges) $
                                            ,/photon,/kev,/earth,/edges,/noline) $
                        +1d5*emhigh*mewe_kev(kev2kel(temphigh)*1d-6,transpose(photedges) $
                                         ,/photon,/kev,/earth,/edges,/noline) 
  ENDIF 


  ;model spectrum, in units photons cm^-2 sec^-1 
  yy=photonout*de

  ;IF exist(background) THEN BEGIN  
  y=drm#yy*geom_area            ;+background ;count spectrum from model in 
     ;in units of counts s^-1 cm^-2 keV^-1 * geom_area = counts s^-1 keV^-1
  ;ENDIF ELSE BEGIN
  ;   y=drm#yy*geom_area ;count spectrum from model in 
     ;in units of counts s^-1 cm^-2 keV^-1 * geom_area = counts s^-1 keV^-1
  ;ENDELSE

  y=y+par[4]*background


  return,y[cntrange]


END
