;+
; NAME:
;      pg_fitpivmodel
;
; PROJECT:
;      spectral modelling
;
; PURPOSE: 
;      fit a pivot point model from input energies and fluxes
;
; EXPLICATION:
;      
;
;
; CALLING SEQUENCE:
;      res=pg_fitpivmodel(fnorm,delta,enorm)
;
; INPUTS:
;      fnorm: an array of normalization fluxes
;      delta: an array of spectral indices
;      enorm: normalization energy
;   
; OUTPUTS:
;      res=[pivot flux, pivot energy, normalization energy]
;      
; KEYWORDS:
;
;
; HISTORY:
;       11-NOV-2005 written PG
;      
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;
;-

FUNCTION pg_fitpivmodel,fnorm,delta,enorm,quiet=quiet,status=status



parinfo=replicate({limited:[1,1],limits:[1d-6,1d6],value:1d,fixed:0,parname:''},3)

parinfo[0].limits=[1d-20,1d20]
parinfo[0].parname='PIVOT FLUX'
parinfo[0].value=1d6


parinfo[1].limits=[1d-5,1d2]
parinfo[1].parname='PIVOT ENERGY'
parinfo[1].value=10d


parinfo[2].fixed=1
parinfo[2].value=enorm
parinfo[2].parname='NORMALIZATION ENERGY'

parms=mpfitfun('pg_pivpoint',fnorm,delta,replicate(1d,n_elements(fnorm)), $
               parinfo=parinfo,quiet=quiet,status=status);


RETURN,parms

   
END
