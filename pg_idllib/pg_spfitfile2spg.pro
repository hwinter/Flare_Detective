;+
; NAME:
;
; pg_spfitfile2spg
;
; PURPOSE:
;
; read a spectrum fits file as written by RHESSI spectrum object using
; the fitswrite method
;
; CATEGORY:
;
; rhessi spectrograms util
;
; CALLING SEQUENCE:
;
; spg=pg_spfitfile2spg(filename)
;
; INPUTS:
;
; filename: name of the RHESSI spectrum fits file
;
; OPTIONAL INPUTS:
;
;
;
; KEYWORD PARAMETERS:
;
; edges: if set, energy edges instead of averages are returned
;
; OUTPUTS:
;
; spg: a spectrogram structure
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
; Paolo Grigis, Institute for Astronomy, ETH Zurich
; pgrigis@astro.phys.ethz.ch 
;
; MODIFICATION HISTORY:
;
; 26-MAR-2004 pg written
; 03-FEB-2004 pg changed routine to accomodate for tag name change in sp
;             files
; 13-APR-2005 pg added keyword for new method (time format changed!)
; 31-OCT-2006 pg added error keyword
; 06-NOV-2006 pg added filter keyword
; 15-JAN-2007 pg added check for filter_state being a scalar if no attenuator
;                change took place: replicate it to a vector with OK length
; 12-FEB-2007 pg added multi keyword
;-

;.comp pg_spfitfile2spg

FUNCTION pg_spfitfile2spg,filename,edges=edges,new=new,error=error,filter=filter,multi=multi

IF NOT file_exist(filename) THEN BEGIN
   print,'The file '+filename+' does not exist!'
   RETURN,-1
ENDIF

;read the spectrogram & time structure
data1=mrdfits(filename,1,header1)

IF keyword_set(filter) THEN BEGIN 
   data3=mrdfits(filename,3,header3)
   filter_state=data3.INTERVAL_ATTEN_STATE$$STATE
   filter_uncert=data3.INTERVAL_ATTEN_STATE$$UNCERTAIN
ENDIF


;stop

if keyword_set(multi) then begin 
   spectrogram=transpose(data1.rate,[2,0,1])
   errspectrogram=transpose(data1.(1),[2,0,1])
endif else begin 
   spectrogram=transpose(data1.rate)
   errspectrogram=transpose(data1.(1))
endelse



IF NOT keyword_set(new) THEN BEGIN 

;convert time from modified julian date...
time_arr=data1.time
anyt_arr=replicate({mjd:0L,time:0L},n_elements(time_arr))

anyt_arr.mjd=floor(time_arr)
anyt_arr.time=(time_arr-floor(time_arr))*3600L*24L*1000L

x=anytim(anyt_arr); final time in anytim format

ENDIF ELSE BEGIN

   hstc=head2stc(header1)
   x= mjd2any(double(hstc.mjdref)+double(hstc.timezero))+ data1[*].time

ENDELSE



data2=mrdfits(filename,2)
edgess=transpose([[data2.e_min],[data2.e_max]])

IF keyword_set(edges) THEN yy=edgess ELSE edge_products,edgess,mean=yy


if keyword_set(multi) then begin

   nmulti=n_elements(spectrogram[0,0,*])
   spgptr=ptrarr(nmulti)

   for i=0,nmulti-1 do begin 
   
   if keyword_set(error) then $
      thisspg={spectrogram:spectrogram[*,*,i],espectrogram:errspectrogram[*,*,i],x:x,y:yy} $
   else thisspg={spectrogram:spectrogram[*,*,i],x:x,y:yy}
   
   spgptr[i]=ptr_new(thisspg)

   endfor

   spg=spgptr

endif else begin

if keyword_set(error) then $
  spg={spectrogram:spectrogram,espectrogram:errspectrogram,x:x,y:yy} $
else spg={spectrogram:spectrogram,x:x,y:yy}

IF keyword_set(filter) THEN BEGIN 
   IF n_elements(filter_state) EQ 1 THEN filter_state=replicate(filter_state,n_elements(spg.x))
   IF n_elements(filter_uncert) EQ 1 THEN filter_uncert=replicate(filter_uncert,n_elements(spg.x))
   spg=add_tag(spg,filter_state,'filter_state')
   spg=add_tag(spg,filter_uncert,'filter_uncert')
ENDIF


endelse



RETURN,spg

END
