;+
; NAME:
;
;   pg_dataforoneevent
;
; PURPOSE:
;
;   generates HSI overview/useful data for one event
;
; CATEGORY:
;
;   RHESSI util
;
; CALLING SEQUENCE:
;
;   pg_dataforoneevent(flareinfo,basdir)
;
; INPUTS:
;
;   flareinfo: a structure with (at least) following tags for the event
;
;     ID_NUMBER       LONG  
;     START_TIME      DOUBLE 
;     END_TIME        DOUBLE 
;     PEAK_TIME       DOUBLE 
;     OBS_START       DOUBLE
;     OBS_END         DOUBLE
;     BCK_TIME        DOUBLE    Array[2]
;     GOES_CLASS: max goes flux between START & END_TIME
;     XPOS: x position of the flare from flare list
;     YPOS: y position of the flare from flare list
;     SPIN_PERIOD: RHESSI spin period at 1/2(START TIME + END TIME)
;     MIN_ATT: minimum attenuator state between START & END TIME
;     MAX_ATT: maximum attenuator state between START & END TIME
;
;   basdir: the rootdir for data generation
;
; OPTIONAL INPUTS:
;
;  
;
; KEYWORD PARAMETERS:
;
;
;
; OUTPUTS:
;
;  as files on the disk
;    
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
; 
;   Paolo Grigis ( pgrigis@astro.phys.ethz.ch )
;
; MODIFICATION HISTORY:
;
;   15-JAN-2007 written PG
;
;-

;.comp  pg_dataforoneevent

PRO pg_dataforoneevent,flareinfo,basdir,outdir=outdir

  IF NOT exist(basdir) THEN BEGIN
     print,'Please input a valid base directory name!'
     return
  ENDIF

  IF NOT file_exist(basdir) THEN BEGIN 
     print,'Please input a valid path for the data!'
     return
  ENDIF

  id=strtrim(flareinfo.id_number,2)
  starttime=flareinfo.start_time

  timest=anytim(starttime,/utc_ext)
  year=strtrim(timest.year,2)
  month=smallint2str(timest.month,strlen=2)
  day=smallint2str(timest.day,strlen=2)

  ps=path_sep()

  dir=basdir+year+ps+month+ps+day+ps+id
  outdir=year+ps+month+ps+day+ps+id+ps

  ;generate new dir or update?
  IF ~file_exist(dir) THEN BEGIN 
     file_mkdir,dir
  ENDIF

  timerange=[flareinfo.obs_start-600,flareinfo.obs_end+600]
  timerange_im=[flareinfo.start_time,flareinfo.end_time]

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ;observing summary

  obssummdir=dir+ps+'obssumm'
  IF ~file_exist(obssummdir) THEN BEGIN 
     file_mkdir,obssummdir
  ENDIF

;  oldplot=!P
  set_plot,'Z'   

  device,/close
  wdef,wind,800,900

  ;ptim,timerange
  ;stop

  obs_summ_page,timerange,/goes
  tvlct,r,g,b,/get
  im=tvrd()
  write_png,obssummdir+ps+'obssumm.png',im,r,g,b

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ;spectrogram

;;;;;;;;;for testing;;;;;;;;;;;;;;
;  timerange='11-dec-2006 '+['01:00','01:02']
;;;;;;;;;for testing;;;;;;;;;;;;;;

  spgdir=dir+ps+'spg'

  IF ~file_exist(spgdir) THEN BEGIN 
     file_mkdir,spgdir
  ENDIF

  energy_band=[3,4,5+findgen(21)/3.,12+findgen(88),100+5*findgen(30),250+10*findgen(26)]

  segment=bytarr(18)
  segment[[1,3,4,5,6,7,9]-1]=1

  sp=hsi_spectrum()

  sp->set,seg_index_mask=segment 
  sp->set,sp_energy_binning=energy_band
  sp->set,sp_semi_calibrated=0
  sp->set,sum_flag=1

  sp->set,use_flare_xyoffset=1
  sp->set,obs_time_interval=timerange
  sp->set,sp_time_interval=flareinfo.spin_period

  sp->set,pileup_correct=0
  spfilename=spgdir+ps+'sp_pileup_00.fits'
  srmfilename=spgdir+ps+'srm_pileup_00.fits'

  sp->filewrite,/fits, /build, srmfile=srmfilename, specfile = spfilename $
               ,all_simplify=0

  sp->set,pileup_correct=1
  sp->set,pileup_tweak=0.6

  spfilename=spgdir+ps+'sp_pileup_06.fits'
  srmfilename=spgdir+ps+'srm_pileup_06.fits'

  sp->filewrite,/fits, /build, srmfile=srmfilename, specfile = spfilename $
               ,all_simplify=0

  sp->set,pileup_correct=1
  sp->set,pileup_tweak=0.8

  spfilename=spgdir+ps+'sp_pileup_08.fits'
  srmfilename=spgdir+ps+'srm_pileup_08.fits'


  sp->filewrite,/fits, /build, srmfile=srmfilename, specfile = spfilename $
               ,all_simplify=0

  sp->set,pileup_correct=1
  sp->set,pileup_tweak=1.

  spfilename=spgdir+ps+'sp_pileup_10.fits'
  srmfilename=spgdir+ps+'srm_pileup_10.fits'

  sp->filewrite,/fits, /build, srmfile=srmfilename, specfile = spfilename $
               ,all_simplify=0

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


  ;spgplots

   r1=0B
   g1=128B
   b1=0B
   r2=255B
   g2=0B
   b2=255B

   device,/close
   wdef,wind,1024,768 

  spgplotdir=dir+ps+'spgplot'
  IF ~file_exist(spgplotdir) THEN BEGIN 
     file_mkdir,spgplotdir
  ENDIF

  ;get particles & attenuator
  qmro=hsi_qlook_monitor_rate(obs_time_interval=timerange)
  qmr=qmro->getdata()
  qmrtimes=qmro->getdata(/xaxis)
  obj_destroy,qmro
  dt=qmrtimes[1]-qmrtimes[0]
  ;done

  spfilename=spgdir+ps+'sp_pileup_00.fits'
  srmfilename=spgdir+ps+'srm_pileup_00.fits'

  spgin=pg_spfitfile2spg(spfilename,/new,/edges,/filter,/error) ;units: counts s^(-1)
  spg=pg_spg_uniformrates(spgin,/convert_edges) ;units: count s^-1 keV^-1

  data=spg.spectrogram
  spg.spectrogram=data>0.

  loadct,5
  tvlct,r,g,b,/get
  r[1]=r1
  g[1]=g1
  b[1]=b1
  r[2]=r2
  g[2]=g2
  b[2]=b2

  spectro_plot,spg,/zlog,/ylog,/ystyle,timerange=timerange,/xstyle,bottom=3
  
  outplot,flareinfo.start_time*[1,1]-spgin.x[0],10^!Y.crange,spgin.x[0],thick=2
  outplot,flareinfo.end_time*[1,1]-spgin.x[0],10^!Y.crange,spgin.x[0],thick=2


  outplot,qmrtimes-qmrtimes[0]+dt/2.,10+qmr.PARTICLE_RATE[1],qmrtimes[0],color=1
  outplot,qmrtimes-qmrtimes[0]+dt/2.,10+qmr.PARTICLE_RATE[0],qmrtimes[0],color=2
	
  plot_label,/NOLINE,/DEV,[0.03,-1],'LO channel',color=2 ;,charsize=charsize/2
  plot_label,/NOLINE,/DEV,[0.03,-2],'HI channel',color=1 ;,charsize=charsize/2

  ;oplot atten

  ;stop

  outplot,spg.x-spg.x[0],spgin.filter_state+4,spg.x[0],thick=3,color=2

  im=tvrd()
  write_png,spgplotdir+ps+'spg_pileup00.png',im,r,g,b


  spfilename=spgdir+ps+'sp_pileup_06.fits'
  srmfilename=spgdir+ps+'srm_pileup_06.fits'

  spgin=pg_spfitfile2spg(spfilename,/new,/edges,/filter,/error) ;units: counts s^(-1)
  spg=pg_spg_uniformrates(spgin,/convert_edges) ;units: count s^-1 keV^-1

  data=spg.spectrogram
  spg.spectrogram=data>0.


  spectro_plot,spg,/zlog,/ylog,/ystyle,timerange=timerange,/xstyle,bottom=3

  outplot,flareinfo.start_time*[1,1]-spgin.x[0],10^!Y.crange,spgin.x[0],thick=2
  outplot,flareinfo.end_time*[1,1]-spgin.x[0],10^!Y.crange,spgin.x[0],thick=2


  outplot,qmrtimes-qmrtimes[0]+dt/2.,10+qmr.PARTICLE_RATE[1],qmrtimes[0],color=1
  outplot,qmrtimes-qmrtimes[0]+dt/2.,10+qmr.PARTICLE_RATE[0],qmrtimes[0],color=2
	
  plot_label,/NOLINE,/DEV,[0.03,-1],'LO channel',color=2 ;,charsize=charsize/2
  plot_label,/NOLINE,/DEV,[0.03,-2],'HI channel',color=1 ;,charsize=charsize/2

  ;oplot atten

  outplot,spg.x-spg.x[0],spgin.filter_state+4,spg.x[0],thick=3,color=2


  im=tvrd()
  write_png,spgplotdir+ps+'spg_pileup06.png',im,r,g,b



  spfilename=spgdir+ps+'sp_pileup_08.fits'
  srmfilename=spgdir+ps+'srm_pileup_08.fits'

  spgin=pg_spfitfile2spg(spfilename,/new,/edges,/filter,/error) ;units: counts s^(-1)
  spg=pg_spg_uniformrates(spgin,/convert_edges) ;units: count s^-1 keV^-1

  data=spg.spectrogram
  spg.spectrogram=data>0.


  spectro_plot,spg,/zlog,/ylog,/ystyle,timerange=timerange,/xstyle,bottom=3

  outplot,flareinfo.start_time*[1,1]-spgin.x[0],10^!Y.crange,spgin.x[0],thick=2
  outplot,flareinfo.end_time*[1,1]-spgin.x[0],10^!Y.crange,spgin.x[0],thick=2


  outplot,qmrtimes-qmrtimes[0]+dt/2.,10+qmr.PARTICLE_RATE[1],qmrtimes[0],color=1
  outplot,qmrtimes-qmrtimes[0]+dt/2.,10+qmr.PARTICLE_RATE[0],qmrtimes[0],color=2
	
  plot_label,/NOLINE,/DEV,[0.03,-1],'LO channel',color=2 ;,charsize=charsize/2
  plot_label,/NOLINE,/DEV,[0.03,-2],'HI channel',color=1 ;,charsize=charsize/2

  ;oplot atten

  outplot,spg.x-spg.x[0],spgin.filter_state+4,spg.x[0],thick=3,color=2


  im=tvrd()
  write_png,spgplotdir+ps+'spg_pileup08.png',im,r,g,b


  spfilename=spgdir+ps+'sp_pileup_10.fits'
  srmfilename=spgdir+ps+'srm_pileup_10.fits'

  spgin=pg_spfitfile2spg(spfilename,/new,/edges,/filter,/error) ;units: counts s^(-1)
  spg=pg_spg_uniformrates(spgin,/convert_edges) ;units: count s^-1 keV^-1

  data=spg.spectrogram
  spg.spectrogram=data>0.


  spectro_plot,spg,/zlog,/ylog,/ystyle,timerange=timerange,/xstyle,bottom=3

  outplot,flareinfo.start_time*[1,1]-spgin.x[0],10^!Y.crange,spgin.x[0],thick=2
  outplot,flareinfo.end_time*[1,1]-spgin.x[0],10^!Y.crange,spgin.x[0],thick=2

  outplot,qmrtimes-qmrtimes[0]+dt/2.,10+qmr.PARTICLE_RATE[1],qmrtimes[0],color=1
  outplot,qmrtimes-qmrtimes[0]+dt/2.,10+qmr.PARTICLE_RATE[0],qmrtimes[0],color=2
	
  plot_label,/NOLINE,/DEV,[0.03,-1],'LO channel',color=2 ;,charsize=charsize/2
  plot_label,/NOLINE,/DEV,[0.03,-2],'HI channel',color=1 ;,charsize=charsize/2

  ;oplot atten

  outplot,spg.x-spg.x[0],spgin.filter_state+4,spg.x[0],thick=3,color=2


  im=tvrd()
  write_png,spgplotdir+ps+'spg_pileup10.png',im,r,g,b

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ;overviewimages

  IF total(flareinfo.xpos^2+flareinfo.ypos^2) NE 0. THEN BEGIN 

     imcubedir=dir+ps+'imcube'
     IF ~file_exist(imcubedir) THEN BEGIN 
        file_mkdir,imcubedir
     ENDIF

     xyoffset=[flareinfo.xpos,flareinfo.ypos]

     pixel_size=2
     image_dim=[256,256]
     det_index_mask=[0,0,1,1,1,1,1,1,0]


     im=hsi_image()

     im->set,det_index_mask=det_index_mask
     im->set,xyoffset=xyoffset
     im->set,pixel_size=pixel_size
     im->set,image_dim=image_dim
     im->set_no_screen_output

     im->set,image_algorithm='clean'
     im->set_no_screen_output
;    im->set,natural_weighting=1
;    im->set,uniform_weighting=1
          
     im->set,im_time_interval=timerange_im
     im->set,im_time_bin=120.
     im->set,im_energy_binning=[6,12,25,50,100]

     im->set, im_out_fits = imcubedir+ps+'imcube_clean_01.fits'
     im->fitswrite


ENDIF
  

END
