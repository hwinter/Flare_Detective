;+
; NAME:
;      pg_gendata
;
; PURPOSE: 
;      generate useful data for spectroscopy of an event
;
; INPUTS:
;      
;
; 
;  
; OUTPUTS:
;      none
;      
; KEYWORDS:
;      
;
; HISTORY:
;       
;     15-FEB-2005 written PG
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;       pgrigis@astro.phys.ethz.ch
;
;-

PRO pg_gendata,time_intv,datadir=datadir,tbin=tbin,segments=segments,ebin=ebin $
              ,basefilename=basefilename,reftime=reftime


ps=path_sep()

IF NOT exist(tbin) THEN BEGIN
   IF NOT exist(reftime) THEN reftime=0.5*total(anytim(time_intv))
   tbin=rhessi_get_spin_period(reftime);get rhessi rotation period at reftime
ENDIF

IF NOT exist(ebin) THEN ebin=7
IF NOT exist(segments) THEN segments=[1,0,1,1,1,1,0,0,1]

IF NOT exist(basefilename) THEN basefilename=time2file(time_intv[0])

IF NOT exist(datadir) THEN datadir=''+ps ELSE datadir=datadir+ps



catfilename=datadir+'catalog.dat'
textcatname=datadir+'catalog.txt'
cat_st={number:0L,time_intv:ptr_new(time_intv),tbin:ptr_new(tbin) $
       ,ebin:ptr_new(ebin),segments:segments,basefilename:basefilename $
       ,success:0B}

IF NOT file_exist(catfilename) THEN BEGIN
   catalog=cat_st
ENDIF ELSE BEGIN
   restore,catfilename
   number=n_elements(catalog)
   cat_st.number=number
   catalog=[catalog,cat_st]
ENDELSE

;generate the data
;
;A: obs_summ_page...

set_plot,'Z'
obs_summ_page,time_intv
tvlct,r,g,b,/get
im=tvrd()
write_png,datadir+'OBSSUMM_'+basefilename+'.png',im,r,g,b
;set_plot,'X'

;B: spectrogram and srm files

spgfile=datadir+'sp_'+basefilename+'.fits'
srmfile=datadir+'srm_'+basefilename+'.fits'

sp=hsi_spectrum()

sp->set,obs_time_interval=time_intv
sp->set,sp_time_interval=tbin
sp->set,seg_index_mask=segments
sp->set,sp_energy_binning=ebin
sp->set,sp_semi_calibrated=0
sp->set,sum_flag=1
 
sp->filewrite, /fits, /build, srmfile=srmfile $
             , specfile=spgfile, all_simplify=0 $
             ,err_msg=err_msg


catalog[n_elements(catalog)-1].success=err_msg EQ ''


save,catalog,filename=catfilename

pg_write_cat2text,catalog,textcatname


;text format of catalog


;read catalogue




END











