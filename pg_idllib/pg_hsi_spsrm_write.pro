;+
; NAME:
;       pg_hsi_spsrm_write
;
; PURPOSE: 
;       generate the spectrum and srm file to use with SPEX
;
; CALLING SEQUENCE:
;       pg_hsi_spsrm_write,time_intv [,optional parameters] 
;
; INPUTS:
;
;       spfilename: filename for the spectrum              
;       srmfilename: filename for the response matrix  
;
;       time_intv: a time interval in a format accepted by the anytim
;                  routine
;       time_bin: the time interval for the spectrogram, in seconds.
;                 Default: 4 seconds 
;       energy_band: energy bands or edges for the spectrogram.
;                    Default: 3 to 500 keV in 1 keV bins
;       segment: HESSI segment mask array with 18 elements
;                Default: 1F 3F 4F 5F 6F 8F 9F 
;       xyoffset: flare position, if not set use pos from flare list
;
;
; OUTPUTS:
;       NONE (files are written)
; 
; KEYWORDS:
;
;       preview: do not generate anything, only print the selected
;                parameters  
;
;
; EXAMPLE:
;      time_intv='26-FEB-2002 '+['10:25','10:30']
;      energy_band=findgen(98)+3
;      time_bin=4.
;      segment=bytarr(18) & segment[0:4]=1
;      pg_hsi_spsrm_write,time_intv,time_bin=time_bin,energy_band=energy_band $
;                        ,segment=segment,spfilename=spfilename $
;                        ,srmfilename=srmfilename,/preview
;
; VERSION
;       
;
; HISTORY
;       03-NOV-2003 written
;       21-APR-2004 added atten_state keyword
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;-

PRO pg_hsi_spsrm_write,time_intv,time_bin=time_bin,energy_band=energy_band $
                      ,segment=segment,spfilename=spfilename,sum_flag=sum_flag $
                      ,srmfilename=srmfilename,preview=preview $
                      ,xyoffset=xyoffset,pileup_correct=pileup_correct $
                      ,all_simplify=all_simplify,atten_state=atten_state

;--------------------------------------------------
;input checking & initializations
;--------------------------------------------------
   
   
   IF n_elements(time_intv) NE 2 THEN BEGIN       
       print,'Please give a time range!'
       print,'No files written'
       RETURN
   ENDIF

   IF n_elements(all_simplify) NE 1 THEN all_simplify=0
 
   IF n_elements(energy_band) LE 1 THEN energy_band=findgen(498)+3.

   sum_flag=fcheck(sum_flag,1)


   edge_products,energy_band,edges_2=eb

   IF n_elements(time_bin) EQ 0 THEN time_bin=4. 
   IF time_bin LE 0 THEN time_bin=4.

   IF n_elements(segment) NE 18 THEN segment=[1,0,1,1,1,1,0,1,1,0,0,0,0,0,0,0,0,0]

   IF n_elements(spfilename) LT 1 THEN spfilename='sp_'+time2file(time_intv[0])+'.fits'
   IF n_elements(srmfilename) LT 1 THEN srmfilename='srm_'+time2file(time_intv[0])+'.fits'

   IF n_elements(xyoffset) NE 2 THEN useflarexy=1 else useflarexy=0



   IF keyword_set(preview) THEN BEGIN

       print,'Spectrogram settings:'
       print,''
       print,'Time interval : '+anytim(time_intv[0],/vms)+' / ' $
                               +anytim(time_intv[1],/vms)
       print,'Time bin      : '+strtrim(string(time_bin),2)+' seconds'
       print,'Energy range  : '+strtrim(string(min(eb)),2)+'-' $
                               +strtrim(string(max(eb)),2)+' keV'
       print,'Segments used : '+hsi_seg2str(segment)

       print,'Spectrum file : '+spfilename
       print,'SRM file      : '+srmfilename

       IF useflarexy THEN $
         print,'Use flare xy offset.' $
       ELSE $
         print,'xy offset     : ['+strtrim(string(xyoffset[0]),2)+','+ $
                                strtrim(string(xyoffset[1]),2)+']'
       
       IF n_elements(atten_state) EQ 1 THEN $
          print,'Attenuator state forced to: '+strtrim(string(atten_state),2)

       print,''


       RETURN
          
   ENDIF
       
;-------------------------------------------------
;RHESSI spectrum object!!!!
;-------------------------------------------------

     sp=hsi_spectrum()

     sp->set,obs_time_interval=time_intv
     sp->set,sp_time_interval=time_bin
     sp->set,seg_index_mask=segment 
     sp->set,sp_energy_binning=eb
     sp->set,sp_semi_calibrated=0
     sp->set,sum_flag=sum_flag

     IF useflarexy EQ 0 THEN BEGIN
         sp->set,use_flare_xyoffset=0
         sp->set,xyoffset=xyoffset
     ENDIF

     IF keyword_set(pileup_correct) THEN $
        sp->set,pileup_correct=1 

;     IF n_elements(atten_state) EQ 1 THEN $
;        sp->set,atten_state=atten_state
     
;sp->set, compute_offax_position = 0
;sp->set, compute_offax_position = 1
     

;---------------------------------------------------------
;write the fits file
;---------------------------------------------------------


;stop


;keyword all_simplify = 0 means complete srm
;                       1 off diag: approx ;--> never use this for
;                       shutter out, seems worse than 2...
;                       2 diagonal


IF n_elements(atten_state) EQ 1 THEN $
  sp->filewrite, /fits, /build, srmfile=srmfilename, specfile = spfilename $
               ,all_simplify=all_simplify,atten_state=atten_state $
 ELSE $
  sp->filewrite, /fits, /build, srmfile=srmfilename, specfile = spfilename $
               ,all_simplify=all_simplify
;stop

;---------------------------------------------------------
;clean up
;---------------------------------------------------------

obj_destroy,sp
   
END














