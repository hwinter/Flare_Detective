;+
; NAME:
;
;   pg_spg_extract_band
;
; PURPOSE:
;   extract a band lightcurve from a spectrogram
;
;
; CATEGORY:
; 
;   spectrogram utilities
;
; CALLING SEQUENCE:
;
;   ltc=pg_spg_extract_band(spg,eband)
;
; INPUTS:
;
;   spg: a spectrogram structure
;   eband: energy band
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
; bandind: min-max of band indices
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
;
;   Paolo Grigis, Institute for Astronomy, ETH, Zurich
;   pgrigis@astro.phys.ethz.ch
;
; MODIFICATION HISTORY:
;
;   02-APR-2004 written, based on hsi_plot_lowen2
;
;-


FUNCTION pg_spg_extract_band,spg,eband,bandind=bandind

   y=spg.y
   ndimy=size(y,/n_dimensions)
   
   IF ndimy EQ 2 THEN $
      ind=where(y[0,*] GE eband[0] AND y[1,*] LE eband[1],count) ELSE $
      ind=where(y GE eband[0] AND y LE eband[1],count)
   IF count EQ 0 THEN return,-1

   bandind=[min(ind),max(ind)]
   ltc=total(spg.spectrogram[*,bandind[0]:bandind[1]],2)

   RETURN,ltc

END











