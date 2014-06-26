;+
; NAME:
;      argos_rcv_temp
;
; PURPOSE: 
;      returns the (frequency dependent) receiver temperature
;
; PROCEDURE:
;      temperature is computed from the Y-factor from the calibration spectra 
;
; CALL SEQUENCE:
;      Trcv=argos_rcv-temp(cal1=cal1,cal2=cal2,t1=t1,t2=t2 [,yfactor=yfactor])
;
;
; INPUTS:
;     cal1,cal2: 2 calibration spectrograms -> if they have more than
;                one measurement each, they are integrated
;     t1,t2: temperature corresponding to the observed calibration spectra
; 
;  
; OUTPUTS:
;     Trcv: frequency dependent rec temp
;     yfactor: optional output, y-factor
;     err: set to 1 if an error happened, otherwise to 0 
;
;
; HISTORY:
;     15-MAR-2004 written PG
;     
;
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;       pgrigis@astro.phys.ethz.ch
;
;-

FUNCTION argos_rcv_temp,cal1=cal1,cal2=cal2,t1=t1,t2=t2,err=err,yfactor=yfactor

err=0

;input checking
IF (NOT exist(t1)) OR (NOT exist(t2)) THEN BEGIN
    print,'Please input a valid T1 and T2!'
    err=1
    RETURN,-1
ENDIF
IF (size(cal1,/tname) NE 'STRUCT') OR (size(cal1,/tname) NE 'STRUCT') THEN BEGIN
    print,'Please input two valid calibration spectra!'
    err=1
    RETURN,-1
ENDIF

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
ENDELSE 


yfactor=transpose(cal2sp/cal1sp)

trcv=(t2-yfactor*t1)/(yfactor-1.)

RETURN,trcv

END



