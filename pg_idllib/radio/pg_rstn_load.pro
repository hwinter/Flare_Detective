;+
; NAME:
;
; pg_rstn_load
;
; PURPOSE:
;
; loads in idl one-day bunch of data from ascii files in the format
; used by the rtsn observatories (tested with data from San Vito)
;
; CATEGORY:
;
; radio
;
; CALLING SEQUENCE:
;
; data=pg_rstn_load(time_intv,datadir=datadir,/time_correct)
;
; INPUTS:
;
; time_intv: a one or two element time array in a format accepted by anytim
;            if one element is given, the data for the whole day is
;            loaded
;            [if two element array, than only data in the
;            time interval is loaded (time_intv should be leaas than a
;            day)] !NOT IMPLEMENTED YET!
;
; OPTIONAL INPUTS:
;
; datadir: location of the directory with the data
;
; KEYWORD PARAMETERS:
;
; time_correct: if set, polish up the time series of the data
; (eliminates time which occur more than once, set NaN for misisng
; times in the file)
; loud: print some status info
;
; OUTPUTS:
;
; data: a spectrogram structure (about 40'000 times by 8 frequencies)
;
; OPTIONAL OUTPUTS:
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
; for now, only whole days can be loaded
;
; PROCEDURE:
;
; read the data from the ASCII file, ocnvert the time string in anytim
; format and optionally "polish up" the data, that is, eliminates
; doubles (two lines in the file with same time) and fill up holes
; (missing times) with NaN
;
; EXAMPLE:
;
;
;
; AUTHOR:
;
; Paolo Grigis, Institute for Astronomy, ETH Zurich
; pgrigis@astro.phys.ethz.ch
;
; MODIFICATION HISTORY:
;
; 04-MAR-2004 written
; 05-MAR-2004 changed output format to spectrogram structure
;
;-

FUNCTION pg_rstn_load,time_intv,time_correct=time_correct $
                     ,datadir=datadir,loud=loud


;find the right filename for input date
filedir=fcheck('/global/saturn/home/hperret/data/rstn/',datadir)

;transform date in ok format
daystr=anytim(time_intv[0],/date_only,/yohkoh)
daystr=strupcase(daystr)
bdaystr=byte(daystr)
daystr=string(bdaystr[[0,1,3,4,5,7,8]])

;ok filename
filename=filedir+daystr+'.LIS'
IF NOT file_exist(filename) THEN BEGIN
   print,'The file '+filename+' does not exist!'
   RETURN,-1
ENDIF

;Template for reading the ascii file

temp={version:1.,datastart:0,delimiter:0B,missingvalue:!values.f_nan, $
       commentsymbol:'',fieldcount:9,fieldtypes:[7,replicate(4,8)], $
       fieldnames:['time','f245','f410','f610','f1415','f2695','f4995' $
                  ,'f8800','f15400'], $
       fieldlocations:[0,19,25,31,37,43,49,55,61], $
       fieldgroups:indgen(9)}


;read in the data
IF keyword_set(loud) THEN $
print,'Loading data from file: '+filename

data=read_ascii(filename,template=temp)

IF keyword_set(loud) THEN $
print,'ASCII file has been read.'

;frequency info
nfreq=8
freqlist=[245.,410,610,1415,2695,4995,8800,15400]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;convert time to anytim format

IF keyword_set(loud) THEN $
print,'Converting time to anytim format.'

ntime=n_elements(data.time)
time_dbl=dblarr(ntime)

FOR i=0L,ntime-1 DO BEGIN

    year  =fix(strmid(data.time[i],4,4))
    month =fix(strmid(data.time[i],8,2))
    day   =fix(strmid(data.time[i],10,2))
    hour  =fix(strmid(data.time[i],12,2))
    minute=fix(strmid(data.time[i],14,2))
    second=fix(strmid(data.time[i],16,2))

    time_dbl[i]=anytim([hour,minute,second,0,day,month,year])

ENDFOR

IF keyword_set(loud) THEN $
print,'Done.'

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;tagnames=tag_names(data)
spectrogram=fltarr(n_elements(time_dbl),nfreq)

FOR i=0,nfreq-1 DO BEGIN 
   spectrogram[*,i]=float(data.(i+1))
ENDFOR

;copy the structure to a new one with ok time format
newdata={spectrogram:spectrogram,x:time_dbl,y:freqlist}

IF keyword_set(loud) THEN $
print,'Raw spectrogram structure is ready.'

;if required, correct time

IF keyword_set(time_correct) THEN BEGIN 

   IF keyword_set(loud) THEN $
   print,'Now starting correction of times.'

   t0=time_dbl[0]
   tlast=time_dbl[n_elements(time_dbl)-1]
   nseconds=tlast-t0
   h=histogram(time_dbl,min=t0-0.5,max=tlast+0.45,binsize=1.)
   newtime=t0+dindgen(nseconds+1)

   ;find indices of doubles to keep/remove
   ind_doubles=where(H GT 1)
   
   FOR i=0,n_elements(ind_doubles)-1 DO BEGIN
      dummy=where(time_dbl EQ newtime[ind_doubles[i]],count)
      IF i eq 0 THEN  $
        ind_remove=dummy[1:count-1] else $
        ind_remove=[ind_remove,dummy[1:count-1]]
   ENDFOR

   h2=histogram(ind_remove,min=-0.5,max=n_elements(time_dbl)-1+0.45)
   ind_keep=where(h2 LT 1)
   ;ind_keep: indices to keep

   ind=where(h GT 0);points with >= 1 data point

   spectrogram2=replicate(!values.f_nan,nseconds+1,nfreq)

   FOR i=0,nfreq-1 DO BEGIN 
      oldlc=newdata.spectrogram[*,i]
      spectrogram2[ind,i]=oldlc[ind_keep]
   ENDFOR 

   newdata2={spectrogram:spectrogram2,x:newtime,y:freqlist}

   IF keyword_set(loud) THEN $
   print,'Corrected spectrogram structure is ready.'

   RETURN,newdata2
   
ENDIF 

RETURN,newdata

END





