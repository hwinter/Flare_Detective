;+
; NAME:
;      argos_snr
;
; PURPOSE: 
;      computes signal to noise ratio from I_source,I_ref,I_zero
;
; PROCEDURE:
;      
;
; CALL SEQUENCE:
;      sp_snr=argos_snr(spsource,spref [,spzero=spzero])
;
;
; INPUTS:
;     spsource: source spectrum or spectrogram
;     spref: reference (background) spectrogram --> if more than one
;            measurement, dat will be integrated
;     spzero: (optional) "dark" spectrum
; 
;  
; OUTPUTS:
;     sp_snr: signal to noise ration
;     err: set to 1 if an error happened, otherwise to 0 
;
;
; HISTORY:
;     15-MAR-2004 written PG
;     
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;       pgrigis@astro.phys.ethz.ch
;
;-

FUNCTION argos_snr,spsource,spref,spzero=spzero,err=err

err=0

;input checking
IF size(spsource,/tname) NE 'STRUCT' THEN BEGIN
    print,'Please input a valid source spectrogram!'
    err=1
    RETURN,-1
ENDIF
IF size(spref,/tname) NE 'STRUCT' THEN BEGIN
    print,'Please input a valid reference spectrogram!'
    err=1
    RETURN,-1
ENDIF


;check if I have to integrate the reference spectrum

ntime=n_elements(spref.x)
IF ntime GT 1 THEN spref_int=argos_intspg(spref) ELSE spref_int=spref
        

;this method is fast but uses more memory!
;alternative method saving memory could be easily implemented
;but would be slower

nfreq=n_elements(spsource.y)    ;number of frequency channels
ntime=n_elements(spsource.x)    ;number of time bins

;expand spref & spzero to a nfreq by ntime array 
spref_blowup=rebin(spref_int.spectrogram,ntime,nfreq)


IF exist(spzero) THEN BEGIN 
    ntime=n_elements(spzero.x)
    IF ntime GT 1 THEN spzero_int=argos_intspg(spzero) ELSE spzero_int=spzero 
    spzero_blowup=rebin(spzero_int.spectrogram,ntime,nfreq)
ENDIF $
ELSE $
  spzero_blowup=0.


sp_snr=spsource

;compute signal to noise ratio
sp_snr.spectrogram=(spsource.spectrogram-spref_blowup)/(spref_blowup-spzero_blowup)

;changes the datalabel tag to 'Kelvin'
sp_snr.datalabel='Signal to Noise Ratio'


RETURN,sp_snr

END



