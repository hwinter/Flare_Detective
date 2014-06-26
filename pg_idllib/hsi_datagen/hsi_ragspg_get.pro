;+
; NAME:
;       hsi_ragspg_get
;
; PURPOSE: 
;       retrieve a spectrogram from a file
;
; CALLING SEQUENCE:
;       spg=hsi_ragspg_get(filename)
;
; INPUTS:
;       filename: name of the file
;       
; KEYWORDS:
;       
;
; HISTORY:
;       10-DEC-2002 written
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;-

FUNCTION hsi_ragspg_get,filename,ragflux=ragflux

;ragfitsread,filename,spg,x,y,dateobs=dateobs

radio_spectro_fits_read,filename,spg,x,y

IF keyword_set(ragflux) THEN BEGIN
spg=10.^(spg/45.)-10.
ENDIF


;x=double(x)+anytim(dateobs)

spgstr={spectrogram:spg,x:x,y:y}

RETURN,spgstr

END


;'45*ln10(solar flux units (sfu) + 10)'
