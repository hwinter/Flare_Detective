;+
; NAME:
;       HSI_SPG_PILEUPCORR_FITSWRITE
;
; PURPOSE: 
;       Make a spectrogram from RHESSI data and (optionally) save it
;       to a fits file. The output format is a structure with fields
;           x: times (average of the time bin)
;           y: energy channels (average of the energy bin)
;           spectrogram: data
;           espectrogram: errors in the data
;           segment: array of the RHESSI segments used
;           type: string ('Flux' or 'Counts')
;           integration_time: time bin width
;
;
; CALLING SEQUENCE:
;       hsi_spg_fitswrite,time_intv [,optional parameters] 
;
; INPUTS:
;
;       time_intv: a time interval in a format accepted by the anytim
;                  routine
;       time_bin: the time interval for the spectrogram, in seconds (default
;                  is 4 seconds) 
;       energy_band: energy band for the spectrogram. Must be 1-dim array.
;                    Default: 3 to 500 keV in 1 keV bins.
;
;       filename: filename with extension (.fit)               
;       scfilename: filename for semical data 
;                   If the filenames are missing, no fits file is written
;
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
;       preview: do not generate anything, only print the selected
;                parameters  
;       front: if set, only front segment counts are used (default: both used)
;       rear:  if set, only rear segment counts are used  (default: both used)
;       pileup: if set, correct for pileup
;
; EXAMPLE:
;
;        time_intv='26-FEB-2002 '+['10:25','10:30']
;        energy_band=findgen(98)+3
;        time_bin=4.
;        segment=bytarr(18) & segment[0:8]=1
;        segment[[1,6]]=0
;        hsi_spg_pileupcorr_fitswrite,time_intv,time_bin=time_bin,energy_band=energy_band $
;            , segment=segment $
;            ,spg=spg,scspg=scspg,/preview,/pileup
;
;
; VERSION
;       2.0 05-MAY-2003
;
; HISTORY
;       26-SEP-2002 written
;       04-OCT-2002 added semicalibrated support  
;       16-OCT-2002 added segment to the spg structure & nofitwrite
;       keyword
;       15-APR-2003 added preview keyword
;       05-MAY-2003 renamed and changed as not to use ragfitswrite
;       04-JUN-2003 added pileup correction functionalities
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;-

PRO hsi_spg_pileupcorr_fitswrite,time_intv,time_bin=time_bin,energy_band=energy_band $
    ,filename=filename,front=front,rear=rear, segment=segment $
    ,spg=spg,scspg=scspg,scfilename=scfilename $
    ,preview=preview,pileup=pileup


;--------------------------------------------------
;input checking & initializations
;--------------------------------------------------

   IF n_elements(time_intv) NE 2 THEN BEGIN
       print,'Please give a time range!'
       RETURN
   ENDIF
 
   IF n_elements(energy_band) LE 1 THEN energy_band=findgen(498)+3.

   IF n_elements(time_bin) EQ 0 THEN time_bin=4. 

   IF n_elements(segment) NE 18 THEN segment=replicate(1B,18)

   IF keyword_set(front) THEN segment[9:17]=0B
   IF keyword_set(rear)  THEN segment[0:8]=0B

   IF keyword_set(preview) THEN BEGIN

       print,'Spectrogram settings:'
       print,''
       print,'Time interval : '+anytim(time_intv[0],/vms)+' / ' $
                               +anytim(time_intv[1],/vms)
       print,'Time bin      : '+strtrim(string(time_bin),2)+' seconds'
       print,'Energy range  : '+strtrim(string(min(energy_band)),2)+'-' $
                               +strtrim(string(max(energy_band)),2)+' keV'
       print,'Segments used : '+hsi_seg2str(segment)
       IF n_elements(filename) EQ 1 THEN BEGIN
           print,'Save to file  :'
           print,'Count spg     : '+filename
           IF n_elements(scfilename) EQ 1 THEN $
               print,'Semical spg   : '+scfilename
       ENDIF ELSE BEGIN
           IF n_elements(scfilename) EQ 1 THEN BEGIN
               print,'Save to file  :'
               print,'Semical spg   : '+scfilename

           ENDIF ELSE $
             print,'No saving to file will be done'
       ENDELSE

       IF keyword_set(pileup) THEN $
           print,'Pileup correction will be applied'

       RETURN
          
   ENDIF
       
;-------------------------------------------------
;RHESSI spectrum object!!!!
;-------------------------------------------------

     sp=hsi_spectrum()

     sp->set,obs_time_interval=time_intv
     sp->set,sp_time_interval=time_bin
     sp->set,seg_index_mask=segment 
     sp->set,sp_energy_binning=energy_band
     sp->set,sp_semi_calibrated=0
     sp->set,sp_data_units='Counts'; means total counts in the energy-time bin
     sp->set,sp_data_structure=1
     sp->set,sum_flag=1
     
;---------------------------------------------------------
;get the data (count spectrum, semicalibrated spectrum)
;---------------------------------------------------------

     sp_struct=sp->getdata()
     sp_par=sp->get()


     IF keyword_set(pileup) THEN BEGIN
         
         ;sp->set,sp_data_structure=1
         ;inspec=sp->getdata()
         
;get data (spectrum)
;os=hsi_spectrum()
;os->set,obs_time_int=tr
;os->set,sp_energy_binning=1
;select a segment
;if keyword_set(segment) then begin
;  det=bytarr(18)
;  det(segment)=1
;endif
;number of segments used
;nseg=total(det)
;os->set,seg_index_mask=det
;select time range
;ttt=max(anytim(tr))-min(anytim(tr))
;os->set,sp_time_interval=ttt
;os->set,time_range=[0,0]
;sp=os->getdata()

;energy axis
;eaxis=os->getaxis()
;de=os->get(/sp_data_de)
;eedge=[eaxis(0)-de(0)/2.,eaxis+de/2.]
;or use
;   os->getaxis(/energy, /edges_2)
;   os->getaxis(/energy)

         eedge=sp->getaxis(/energy, /edges_2)

;get live time
         print,'now getting live time ...'

         o=hsi_monitor_rate()
         o->set,obs_time_interval=time_intv
;     sp->set,sp_time_interval=time_bin
         ;o->set,det_index_mask=segment 
     ;sp->set,sp_energy_binning=energy_band
     ;sp->set,sp_semi_calibrated=0
     ;sp->set,sp_data_units='Counts'; means total counts in the energy-time bin
     ;sp->set,sp_data_structure=1
     ;sp->set,sum_flag=1
         
         d=o->getdata()
         s=o->get()

;t=d.time+s.mon_ut_ref
;time=t
;ttitle=strmid(anytim(time(0),/yy),0,20)+' - '+strmid(anytim(max(time),/yy),10,10)

;         ltime=d.live_time[0]

;ltitle='live time = '+strtrim(fix(100*average(ltime)+0.5),2)+'%'
;print,'averaged live time is '+average(ltime)*100+' %'

;david's pile up program
;inspec=sp
         FOR tim=0,n_elements(sp_struct)-1 DO BEGIN
             wh=where(segment NE 0)
             livetime=total(d[tim].live_time[wh])/n_elements(wh)

             inspec=sp_struct[tim].counts
         
             hsi_correct_pileup,inspec,eedge,livetime*0.4,outspec
             sp_struct[tim].counts=outspec


             n=n_elements(energy_band)
             yaxis=fltarr(n-1)
             yaxis=(0.5*(energy_band+shift(energy_band,-1)))[0:n-2]
             xaxis=0.5*(sp_struct[*].ut[0]+sp_struct[*].ut[1])

             spg={spectrogram:transpose(sp_struct.counts),x:xaxis,y:yaxis $
                  ,segment:segment,type:sp_par.sp_data_unit,ltime:sp_struct.ltime $
                  ,espectrogram:transpose(sp_struct.ecounts),integration_time:time_bin}

             RETURN

         ENDFOR

         

     ENDIF
; plot,energy_band,inspec,/xlog,/ylog 
; oplot,energy_band,outspec,color=120

     sp->set,sp_semi_calibrated=1
     sp->set,sp_data_unit='Flux'; means photons cm^-2 s^-1 keV^-1

     sp_scstruct=sp->getdata()
     sp_scpar=sp->get()
     
;---------------------------------------------------------
;compute the x and y axis
;--------------------------------------------------------- 

     n=n_elements(energy_band)
     yaxis=fltarr(n-1)
     yaxis=(0.5*(energy_band+shift(energy_band,-1)))[0:n-2]
     xaxis=0.5*(sp_struct[*].ut[0]+sp_struct[*].ut[1])

;---------------------------------------------------------
;build the structure for the count spectrogram
;--------------------------------------------------------- 

     spg={spectrogram:transpose(sp_struct.counts),x:xaxis,y:yaxis $
         ,segment:segment,type:sp_par.sp_data_unit,ltime:sp_struct.ltime $
         ,espectrogram:transpose(sp_struct.ecounts),integration_time:time_bin}

     scspg={spectrogram:transpose(sp_scstruct.flux),x:xaxis,y:yaxis $
           ,segment:segment,type:sp_par.sp_data_unit,ltime:sp_struct.ltime $
           ,espectrogram:transpose(sp_scstruct.eflux),integration_time:time_bin}

;---------------------------------------------------------
;write the fits file
;---------------------------------------------------------

     IF n_elements(filename) EQ 1 THEN BEGIN
         mwrfits,spg,filename
     ENDIF

     IF n_elements(scfilename) EQ 1 THEN BEGIN
         mwrfits,scspg,scfilename
     ENDIF

;---------------------------------------------------------
;clean up
;---------------------------------------------------------

   obj_destroy,sp
   
END














