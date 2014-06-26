;+
; NAME:
;      pg_el2phot_thin
;
; PURPOSE: 
;      Transform an input electron spectrum flux (el. s^-1 cm^-2
;      keV^-1) given as an array of values for a discrete set of
;      energies into an emitted photon spectrum in units of
;      photons s^-1 cm^-3 keV^-1.
;      This correspond to the so-called "thin-target" emission.
;
; CALLING SEQUENCE:
;      photsp=pg_el2phot_thin(elsp=elsp,ele=ele,phe=phe,z=z [optional keywords])
;
; INPUTS:
;      elsp: array of N elements with the electron spectrum
;      ele:  array of N elements with the elctron energies
;      phe:  array of M elements with the desired photon energies
;      z:    mean atomic number in target
;
; KEYWORDS:
;      
;
; OUTPUT:
;      photsp: photon spectrum at energies eph
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
;       31-OCT-2005 added physical normalization constants
;       07-NOV-2005 changed integration scheme to faster and
;                   more robust routine pg_inttab
;       14-NOV-2005 definitive version 1.0, el density spectrum allowed
;       
; AUTHOR:
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;-

FUNCTION pg_el2phot_thin,elsp=elsp,ele=ele,phe=phe,z=z $
  ,distance=distance,volumetar=volumetar,densitytar=densitytar $
  ,coulomblog=coulomblog,eldensity=eldensity,_extra=_extra

;for the thin target situation, the coulomb logarithm
;is irrelevent. However, the keyword coulomblog
;is allowed, but ignored, such that formally
;one can call pg_el2phot_thin & pg_el2phot_thick with the same
;syntax

;check inputs & set default values if needed
volumetar=fcheck(volumetar,1d27);target volume in cm^3
densitytar=fcheck(densitytar,1d10);target denisty, ions cm^-3
distance=fcheck(distance,1.496d13);distance from source, default: 1 AU
z=fcheck(z,1.)

mc2   = 510.998918d ;rest mass of the electron, in keV
c=2.99792458d10;speed of light


IF keyword_set(eldensity) THEN BEGIN 
   gamma=1d +ele/mc2
   beta=sqrt(1d -1d /(gamma*gamma))
   elspflux=elsp*c*beta
ENDIF $
ELSE BEGIN 
   elspflux=elsp
ENDELSE 


nph=n_elements(phe)
photsp=dblarr(nph)

IF max(phe) GE 0.5*max(ele) THEN BEGIN 
   print,'To get meaningful results out of this routine one should'
   print,'have that the max electron energy is larger than at least'
   print,'twice the max photon energy!'
   RETURN,-1
ENDIF

brem_cross='pg_brem_genbh'

;loops over photon energies, needed beacuse of the cross section
;and integration thereof
FOR i=0,nph-1 DO BEGIN 

   xin=ele
   yin=elspflux*call_function(brem_cross,phe[i],ele,z,_extra=_extra)
   photsp[i]=pg_tabint(xin,yin)

ENDFOR 


RETURN,photsp*volumetar*densitytar/(4*!DPi*distance*distance)

END

