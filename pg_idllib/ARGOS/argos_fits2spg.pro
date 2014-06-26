;+
; NAME:
;      argos_fits2spg
;
; PURPOSE: 
;      reads an ARGOS FITS file and output a spectrogram structure
;
; PROCEDURE:
;      uses mrdfits to read the FITS file
;
; CALL SEQUENCE:
;      spg=argos_fits2spg(filename)
;
;
; INPUTS:
;      filename: full path to FITS file name
; 
;  
; OUTPUTS:
;     spg: a spectrogram structure, contains  the follwing tags:
;              spectrogram: actual data
;              x,y: x,y axis (time and frequenxy, mostly)
;              additional info TBD
;     
;
; HISTORY:
;     14-MAR-2004 written PG
;     15-MAR-2004 added datalabel
;     17-MAR-2004 added x,y-offset to the structure
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;       pgrigis@astro.phys.ethz.ch
;
;-

FUNCTION argos_fits2spg,filename,err=err,header0=header0,header1=header1,silent=silent

err=0

IF NOT file_exist(filename) THEN BEGIN

    err=1

    IF size(filename,/tname) EQ 'STRING' THEN $
       print,'COULD NOT FIND FILE: '+filename $
    ELSE $
       print,'INPUT A VALID FILE NAME!'

    RETURN,-1

ENDIF


;read raw data
data0=mrdfits(filename,0,hdr0,silent=silent);contains the spectrogram
data1=mrdfits(filename,1,hdr1,silent=silent);contains time/frequency axis

;get header data into an IDL structure
header0=head2stc(hdr0)
header1=head2stc(hdr1)


freq=data1.frequency
freqoffset=double(header0.ac_bfre)

;get the time --> take start observation + long in data1.time*delta time
time=data1.time*double(header0.cdelt1);+anytim(header0.date__obs+header0.time__obs)
timeoffset=anytim(header0.date__obs+header0.time__obs)

spg={spectrogram:data0,x:time,y:freq,xoffset:timeoffset,yoffset:freqoffset $
    ,xlabel:header0.ctype1,ylabel:header0.ctype2,datalabel:'DIGITS'}

RETURN,spg

END



