;+
; NAME:
;      argos_calibrate_sp
;
; PURPOSE: 
;      calibration of a spectrum or spectrogram
;
; PROCEDURE:
;      uses a linear interpolation between the two reference spectra
;
; CALL SEQUENCE:
;      out_sp=argos_calibrate_sp(sp,cal1=cal1,cal2=cal2,t1=t1,t2=t2,err=err)
;
;
; INPUTS:
;     sp: ARGOS observed spectrum or spectrogram
;     cal1,cal2: 2 calibration spectrograms, if they contain more than
;                one spectrum they will automatically be integrated...
;                                           
;     t1,t2: temperature corresponding to the observed calibration spectra
; 
;  
; OUTPUTS:
;     out_sp:a calibrated spectrum in temperature
;     err: set to 1 if an error happened, otherwise to 0 
;
;
; HISTORY:
;     14-MAR-2004 written PG
;     15-MAR-2004 now accepts spectrogram format as input PG
;
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;       pgrigis@astro.phys.ethz.ch
;
;-

FUNCTION argos_calibrate_sp,sp,cal1=cal1,cal2=cal2,t1=t1,t2=t2,err=err

err=0

;input checking
IF (NOT exist(t1)) OR (NOT exist(t2)) THEN BEGIN
    print,'Please input a valid T1 and T2!'
    err=1
    RETURN,-1
ENDIF
IF (NOT exist(cal1)) OR (NOT exist(cal2)) THEN BEGIN
    print,'Please input two valid calibration spectra!'
    err=1
    RETURN,-1
ENDIF

;check if input is a spectrum or a spectrogram
IF size(sp,/tname) EQ 'STRUCT' THEN BEGIN

    ;this method is fast but uses more memory!
    ;alternative method saving memory could be easily implemented
    ;but would be slower

    nfreq=n_elements(sp.y);number of frequency channels
    ntime=n_elements(sp.x);number of time bins


    ;check if I have to integrate the calibration spectra...
    ntime_cal1=n_elements(cal1.x)
    ntime_cal2=n_elements(cal2.x)
    
    IF ntime_cal1 EQ 1 THEN $
        cal1sp=cal1.spectrogram[0,*] $
    ELSE BEGIN 
        intcal1=argos_intspg(cal1)
        cal1sp=intcal1.spectrogram[0,*]
    ENDELSE 

    IF ntime_cal2 EQ 1 THEN $
        cal2sp=cal2.spectrogram[0,*] $
    ELSE BEGIN 
        intcal2=argos_intspg(cal2)
        cal2sp=intcal2.spectrogram[0,*]
    ENDelse


    ;expand cal1 & cal2 to a nfreq 
    cal1_blowup=rebin(cal1sp,ntime,nfreq)
    cal2_blowup=rebin(cal2sp,ntime,nfreq)

    outsp=sp
    ;linear transformation of the spectrum
    outsp.spectrogram= $
        t1+(sp.spectrogram-cal1_blowup)/(cal2_blowup-cal1_blowup)*(t2-t1)

    ;changes the datalabel tag to 'Kelvin'
    sp.datalabel='Kelvin'

 

ENDIF ELSE BEGIN

    print,'Please input a valid spectrogram structure!'
    err=1
    RETURN,-1
    
    ;linear transformation of the spectrum
    ;outsp=t1+(sp-cal1)/(cal2-cal1)*(t2-t1)
ENDELSE


RETURN,outsp

END



