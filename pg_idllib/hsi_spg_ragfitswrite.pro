;+
; NAME:
;       HSI_SPG_RAGFITSWRITE
;
; PURPOSE: 
;       Make a spectrogram from RHESSI data and save it to a rag fits file.
;
; CALLING SEQUENCE:
;       hsi_spg_ragfitswrite,time_intv [,optional parameters] 
;
; INPUTS:
;
;       time_intv: a time interval in a format accepted by the anytim
;                  routine
;       time_bin: the time interval for the spectrogram, in seconds (default
;                  is 4 seconds) 
;       energy_band: energy band for the spectrogram. Must be 1-dim array.
;                    Default: 3 to 500 keV in 1 keV bins.
;                    Example: [3,5,10,15,20,30,50,100]
;       filename: filename with extension (.fit)               
;       scfilename: filename for semical data 
;
;       scaling: if set, scale the values in the spectrogram. Possible values:
;                'byte' : 8 bit
;                'integer': 16 bit
;                'longint': 32 bit
;       segment: HESSI segment mask array with 18 elements
;
; OUTPUTS:
;       spg: contains the count spectrogram, in a structure.
;       scspg: contains the semicalibrated count spectrogram, in a structure. 
;
;       the structure contains:
;           x: times
;           y: energy channels
;           spectrogram: data
;           segment: array of the RHESSI segments used
;           type: string ('semical' or 'count')
; 
; KEYWORDS:
;
;       preview: do not generate anything, only print the selected parameters  ;       front: if set, only front segment counts are used (default: both used) 
;       rear:  if set, only rear segment counts are used (default: both used)
;       rappviewer: optimize the file for the rapp viewer, this keyword
;                   overrides the scaling and invert keyword
;       invert: if set, invert the direction of the y-axis
;       nofitwrite: if set, no output file is produced
;
;
; VERSION
;       1.1 04-OCT-2002
;
; HISTORY
;       26-SEP-2002 written
;       04-OCT-2002 added semicalibrated support  
;       16-OCT-2002 added segment to the spg structure & nofitwrite
;       keyword
;       15-APR-2003 added preview keyword
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;-

PRO HSI_SPG_RAGFITSWRITE,time_intv,time_bin=time_bin,energy_band=energy_band $
    ,filename=filename,front=front,rear=rear,scaling=scaling,invert=invert $
    ,rappviewer=rappviewer,segment=segment,spg=spg,scspg=scspg $
    ,scfilename=scfilename,nofitwrite=nofitwrite,preview=preview


;--------------------------------------------------
;input checking & initializations
;--------------------------------------------------

   IF keyword_set(rappviewer) THEN BEGIN
      scaling='byte'
      invert=1
   END
   IF n_elements(time_intv) EQ 0 THEN BEGIN
      print,'Please give a time range!'
      return
      ENDIF
 
   IF n_elements(energy_band) LE 1 THEN energy_band=findgen(498)+3

   IF n_elements(time_bin) NE 1 THEN time_bin=4.

   IF n_elements(filename) EQ 0 THEN BEGIN
       filename='spg'+anytim(time_intv[0],/ccsds)+'.fits'
   ENDIF

;   IF n_elements(scfilename) EQ 0 THEN BEGIN
;       scfilename='scspg'+anytim(time_intv[0],/ccsds)+'.fits'
;   ENDIF



   IF n_elements(segment) NE 18 THEN segment=[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]
   IF keyword_set(front) THEN segment=[1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0]  
   IF keyword_set(rear)  THEN segment=[0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1] 

   time_intv=anytim(time_intv)
   delta_t=time_intv[1]-time_intv[0]
   time0=anytim(time_intv[0],/time_only)
   date0=anytim(time_intv[0],/date_only)


   IF keyword_set(preview) THEN BEGIN

       print,'Spectrogram settings:'
       print,''
       print,'Time interval : '+anytim(time_intv,/vms)
       print,'Time bin      : '+strtrim(string(time_bin),2)+' seconds'
       print,'Energy range  : '+strtrim(string(min(energy_band)),2)+'-' $
                               +strtrim(string(max(energy_band)),2)+' keV'
       print,'Segments used : '+hsi_seg2str(segment)
       IF NOT keyword_set(nofitwrite) THEN BEGIN
           print,'Save files    : '
           print,filename
           IF exist(scfilename) THEN $
               print,scfilename
          
       ENDIF
       
       RETURN
   END

;-------------------------------------------------
;RHESSI lightcurve
;-------------------------------------------------

   lc=hsi_lightcurve()
   lc->set,obs_time_interval=time_intv
   lc->set,ltc_time_resolution=time_bin 
   lc->set,seg_index_mask=segment 
   lc->set,ltc_energy_band=energy_band


   delta_t=time_intv[1]-time_intv[0]
   x=findgen(delta_t/time_bin)*4
   lc->set,ltc_time_range=[0,delta_t]

   spectrogram=lc->getdata()
   spectrogram=spectrogram/time_bin
   
;---------------------------------------------------------
;compute the x and y axis
;--------------------------------------------------------- 

   s=size(spectrogram)
   x=dblarr(s[1])
   FOR i=0,s[1]-1 DO x[i]=time0+(i+0.5)*time_bin
   y=fltarr(s[2])
   IF keyword_set(invert) THEN $
   FOR i=0,s[2]-1 DO y[s[2]-1-i]=energy_band[i]+0.5*(energy_band[i+1]-energy_band[i]) $
   ELSE $
   FOR i=0,s[2]-1 DO y[i]=energy_band[i]+0.5*(energy_band[i+1]-energy_band[i])

;---------------------------------------------------------
;write the fits file
;---------------------------------------------------------

   IF not exist(nofitwrite) THEN $
     ragfitswrite,spectrogram,x,y,content='RHESSI SPECTROGRAM',telescope=' ' $
     ,instrument='RHESSI',dateobs=anytim(time_intv[0],/date_only,/ecs) $ 
     ,dateend=anytim(time_intv[1],/date_only,/ecs),filename=filename $
     ,bunit='Counts per second',ctype1='TIME',ctype2='ENERGY (keV)' $
     ,scaling=scaling


;---------------------------------------------------------
;compute semicalibrated data and save it if needed
;---------------------------------------------------------
 
  lc->set,SP_SEMI_CALIBRATED=1

  spectrogram2=lc->getdata()
  spectrogram2=spectrogram2/time_bin
  
  IF exist(scfilename) THEN BEGIN  


      ragfitswrite,spectrogram2,x,y,content='RHESSI SPECTROGRAM',telescope=' ',$
         instrument='RHESSI',dateobs=anytim(time_intv[0],/date_only,/ecs),$ 
         dateend=anytim(time_intv[1],/date_only,/ecs),filename=scfilename,$
         bunit='Counts per second',ctype1='TIME',ctype2='ENERGY (keV)',$
         scaling=scaling

   ENDIF
;-------------------------------------------------
;write the output structure
;-------------------------------------------------

   x=anytim(x)+date0
   spg={spectrogram:spectrogram,x:x,y:y,segment:segment,type:'count'}
   scspg={spectrogram:spectrogram2,x:x,y:y,segment:segment,type:'semical'}

   obj_destroy,lc
   
END














