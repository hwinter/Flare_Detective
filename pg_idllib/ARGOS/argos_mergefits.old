;+
; NAME:
;      argos_mergefits
;
; PURPOSE: 
;      merges ARGOS FITS files togheter
;
; PROCEDURE:
;      read the FITS files, check that the number & values of the
;      frequencies agree, merge the data & write a new FITS file
;
; CALL SEQUENCE:
;      argos_mergefits,filelist,outfile=outfile
;
;
; INPUTS:
;      filelist: array of strings of FITS filenames
;      outfile: name of the merged FITS file to write
;  
; OUTPUTS:
;      spg: optional spectrogram with the data from all files
;      err: arror satus, 0 if no error occurred
;
; HISTORY:
;     17/18-MAR-2004 written PG
;     
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;       pgrigis@astro.phys.ethz.ch
;
;-

PRO  argos_mergefits,filelist,spg=spg,outfile=outfile,err=err

err=0

IF NOT exist(filelist) THEN BEGIN

    err=1
    print,'PLEASE INPUT A FILE LIST'
    RETURN

ENDIF

n=n_elements(filelist)


IF NOT exist(outfile) THEN BEGIN

    print,'WARNING: NO OUTPUT FILE GIVEN, NO FITS FILE WILL BE WRITTEN'

ENDIF ELSE BEGIN 

    IF file_exist(outfile) THEN BEGIN  

        err=1
        print,'ERROR: OUTPUT FILE ALREADY EXIST!'
        RETURN

    ENDIF

ENDELSE



IF size(filelist,/tname) NE 'STRING' THEN BEGIN
    
    err=1
    print,'ERROR: INVALID FILE LIST'
    RETURN

ENDIF


IF n LT 2 THEN BEGIN
    err=1
    print,'PROVIDE A LIST WITH AT LEAST 2 FILES'
    RETURN
ENDIF


IF NOT file_exist(filelist[0]) THEN BEGIN
    err=1
    print,'ERROR: COULD NOT FIND FILE: '+filelist[0]
    RETURN
ENDIF


;read raw data
data0=mrdfits(filelist[0],0,hdr0,silent=silent);contains the spectrogram
data1=mrdfits(filelist[0],1,hdr1,silent=silent);contains time/frequency axis

;FITS headers
header0=head2stc(hdr0)
header1=head2stc(hdr1)

freq=data1.frequency
freqoffset=double(header0.ac_bfre)

;get the time --> take start observation + long in data1.time*delta time
time=data1.time*double(header0.cdelt1)
timeoffset=anytim(header0.date__obs+header0.time__obs)

dim=size(data0,/dimensions)

nfreq=dim[1]
ntime=dim[0]


FOR i=1,n-1 DO BEGIN

    IF NOT file_exist(filelist[i]) THEN BEGIN
        err=1
        print,'ERROR: COULD NOT FIND FILE: '+filelist[i]
        RETURN
    ENDIF
   
    newdata0=mrdfits(filelist[i],0,newhdr0,silent=silent)
    newdata1=mrdfits(filelist[i],1,newhdr1,silent=silent)

    newheader0=head2stc(newhdr0)

    newtime=newdata1.time*double(newheader0.cdelt1)
    newtimeoffset=anytim(newheader0.date__obs+newheader0.time__obs)

    newfreq=newdata1.frequency
    newfreqoffset=double(newheader0.ac_bfre)

    ;check if data dimension agree
    newdim=size(newdata0,/dimensions)
    IF newdim[1] NE nfreq THEN BEGIN
        err=1
        print,'ERROR: DATA DIMENSION DO NOT AGREE'
        print,'PROBLEM WITH FILE :'+filelist[i]
        RETURN
    ENDIF

    ;check if frequency agree up to tolerance tol

    tol=1d-6

    newfreq=(newfreqoffset-freqoffset)+newfreq
    IF max(abs(newfreq-freq)) GT tol THEN BEGIN
        err=1
        print,'ERROR: FREQUENCIES IN THE FILES DO NOT AGREE'
        print,'PROBLEM WITH FILE :'+filelist[i]
        RETURN
    ENDIF


    ;merge the data
    data0=[data0,newdata0]
    
    ;merge the times
    newtime=(newtimeoffset-timeoffset)+newtime
    time=[time,newtime]

ENDFOR 


;write a new FITS file...
IF size(outfile,/tname) EQ 'STRING' THEN BEGIN 
    mwrfits,data0,outfile,hdr0,/create
    outst={time:time,frequency:freq}
    mwrfits,outst,outfile,hdr1
ENDIF


spg={spectrogram:data0,x:time,y:freq,xoffset:timeoffset,yoffset:freqoffset $
    ,xlabel:header0.ctype1,ylabel:header0.ctype2,datalabel:'DIGITS'}

RETURN


END



