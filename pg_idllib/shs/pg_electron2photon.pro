;+
; NAME:
;
; pg_electron2photon
;
; PURPOSE:
;
; transform electron spectra into photon spectra 
;
; CATEGORY:
;
; shs project util, spex util
;
; CALLING SEQUENCE:
;
; out= pg_electron2photon(flux, spindex [, elenergy, phenergy] )
;
; INPUTS:
;
; flux: electron flux normalization at normalization energy
; spindex: electron spectral index 
; elenergy: electron normalization energy (default is 35 keV)
; phenergy: photon normalization energy (default is elenergy)
; 
; OUTPUTS:
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
; transformation formulae explained in phot_el_spectrum.tex in this directory
;
; EXAMPLE:
;
;
;
; AUTHOR:
;
; Paolo Grigis, Institute of Astronomy, ETH Zurich
; pgrigis@astro.pyhs.ethz.ch
; 
; MODIFICATION HISTORY:
;
; 23-JUN-2004 written P.G.
;
;-

FUNCTION pg_electron2photon,elflux,spindex,elenergy,phenergy

elenergy=fcheck(elenergy,35)
phenergy=fcheck(phenergy,elenergy)

K=6.44d33

delta=spindex
gamma=delta-1

phflux=1/K*elflux*(elenergy/phenergy)^delta*phenergy $
       *beta(delta-2,0.5)/((delta-1)*(delta-2))

return, {phflux:phflux,phspindex:gamma,phenergy:phenergy}

END
