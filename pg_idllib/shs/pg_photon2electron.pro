;+
; NAME:
;
; pg_photon2electron
;
; PURPOSE:
;
; transform photon spectra into electron spectra 
;
; CATEGORY:
;
; shs project util, spex util
;
; CALLING SEQUENCE:
;
; out= pg_photon2electron(flux, spindex [, phenergy, elenergy] )
;
; INPUTS:
;
; flux: photon flux normalization at normalization energy
; spindex: photon spectral index 
; phenergy: photon normalization energy (default is 35 keV)
; elenergy: electron normalization energy (default is phenergy)
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
; 22-JUN-2004 written P.G.
; 28-JUN-2004 corrected bug that cause incorrect results if input
;             energies were integers
;
;-

FUNCTION pg_photon2electron,phflux,spindex,phenergy,elenergy

phenergy0=double(fcheck(phenergy,35))
elenergy0=double(fcheck(elenergy,phenergy0))


K=6.44d33

gamma=spindex
delta=gamma+1

elflux=K*phflux*(phenergy0/elenergy0)^gamma/elenergy0*gamma*(gamma-1)/beta(gamma-1,0.5)

return, {elflux:elflux,elspindex:delta,elenergy:elenergy}

END
