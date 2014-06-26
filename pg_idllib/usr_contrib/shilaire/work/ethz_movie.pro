;+
;NAME:
;	ethz_movie.pro
;PROJECT:
;	ETHZ - Institut fuer Astronomie
;CATEGORY:
; 
;PURPOSE:
;	Movie making
;PLANNED IMPROVEMENT:
;	List is too long...
;	Twin color table to accomodate polarization images/spg ?
;CALLING SEQUENCE:
;
;INPUT:
;
;OPTIONAL INPUT:	
;
;OUTPUT:
;
;KEYWORDS:
;
;RESTRICTIONS:
;	This routine all necessary data files have downloaded to the data_dir directory (TRACE/EIT, NANCAY), and ONLY those !.
;
;EXAMPLE:
;	ethz_movie, '2002/02/26 '+['10:25:35','10:26:55'],'/global/hercules/users/shilaire/movie_temp',movie=movie,xyoffset=[925,-225],min_hsi_countrates=[200,200,200,200,200,200]
;
;HISTORY:
;	PSH, December 2002 written.
;
;-


;============================================================================================
FUNCTION ethz_movie_return_xyoffset,time_intv, data_dir
	;find peak time in 12-25keV, using Obs. Summary.
	coord=rhessi_find_flare_position(peaktime)
	IF N_ELEMENTS(coord) EQ 1 THEN BEGIN
		;HESSI has failed. Take TRACE's FOV center as xyoffset ?:
		map=ethz_movie_return_trace_map(time_intv,data_dir)
		IF datatype(map) NE 'STC' THEN MESSAGE,'.......Both HESSI and TRACE fail to give me an xyoffset... ABORT the whole thing...!' ELSE coord=[map.XC,map.YC]
	ENDIF
	RETURN,coord
END
;============================================================================================
;picks first TRACE image available in directory data_dir, and within the specified time_intv.
; returns -1 if a problem occured (e.g. no data found within specified time range...).
FUNCTION ethz_movie_return_trace_map, time_intv, data_dir
	;1) look in all hourly files (if any), e.g.: tri20010615.0900 

	;2) look in all files containing single images, e.g.: tri20020226.1000_0078.pl
	tmp=anytim(time_intv[0],/EX)
	file_patt=data_dir+'/tri'+int2str(tmp[6],4)+int2str(tmp[5],2)+int2str(tmp[4],2)+'.*_*.pl'
	filelist=FINDFILE(file_patt)
	i=N_ELEMENTS(filelist)
	IF i EQ 0 THEN BEGIN
		PRINT,'........no matching TRACE files, apparently..., returning -1.'
		RETURN,-1
	ENDIF
	i=i-1
	WHILE i GE 0 DO BEGIN
		fits2map,filelist[i],map
		IF ( (anytim(map.time) GE anytim(time_intv[0])) AND (anytim(map.time) LE anytim(time_intv[1])) ) THEN RETURN,map
		i=i-1
	ENDWHILE
	;if I reached this point, means I did not find proper images.
	PRINT,'.....apparently, none of the TRACE files are within time_intv ...'
	RETURN,-1
END
;============================================================================================
; returns -1 if a problem occured (e.g. no data found within specified time range...).
FUNCTION ethz_movie_return_nrh_map, time_intv, freq,data_dir, V=V, min_tb=min_tb
	;1) look in all image fits files (if any), e.g.: nrh2_4320_h80_19990908_115948c00_i.fts 

	;2) look in daily 10-sec integrated data, e.g.: 2i020226.01
	tmp=anytim(time_intv[0],/EX)
	file_patt=data_dir+'/2i'+int2str(tmp[6],2)+int2str(tmp[5],2)+int2str(tmp[4],2)+'.01'
	filelist=FINDFILE(file_patt)
	IF N_ELEMENTS(filelist) EQ 0 THEN RETURN,-1

	break_file,filelist[0], DISK_LOG, DIR, FILNAM, EXT, FVERSION, NODE
	modified_read_nrh,FILNAM+EXT,freq=freq,STOKES=V,dir=dir,size=512,hbeg=anytim(time_intv[0],/ECS,/time),hend=anytim(time_intv[1],/ECS,/time),index,data		
	index2map,index[0],data[*,*,0],map
	IF KEYWORD_SET(min_tb) THEN IF MAX(map.data) LT min_tb THEN RETURN,-1
	RETURN,map		
END
;=============================================================================================================
FUNCTION ethz_movie_return_hsi_map,time_intv,eband, xyoffset, min_hsi_countrates, os_eband=os_eband

	IF KEYWORD_SET(min_hsi_countrates) THEN BEGIN
		rates=hessi_corrected_os_countrate(time_intv)
		IF NOT KEYWORD_SET(os_eband) THEN os_eband=2
		maxcountrate=0
		FOR i=0,N_ELEMENTS(os_eband)-1 DO maxcountrate=maxcountrate+MAX(rates[os_eband[i],*])
		IF maxcountrate LT min_hsi_countrates THEN RETURN,-1
	ENDIF
	
	imo=hsi_image()
	imo->set,time_range=time_intv,energy_band=eband
	imo->set,xyoffset=xyoffset, pixel_size=1, image_dim=128, det_index=[0,0,1,1,1,1,1,1,0]
;	imo->set,image_alg='clean'
	imo->set_no_screen_output
	tmp=imo->getdata()
	map=make_hsi_map(imo)
	OBJ_DESTROY,imo
	RETURN,map
END
;================================================================================================================================================
;================================================================================================================================================
PRO ethz_movie_compute_time_prof,info_stc,data_stc
	;1) Phoenix-2 spg - Stokes I
	IF info_stc.phoenix_spg_I GT 0 THEN BEGIN
		tmp=rapp_get_spectrogram(info_stc.time_intv,xaxis=xaxis,yaxis=yaxis,/BACK,/ELIM,/LOG)
		newstc={phnx_spg_I:tmp,phnx_xaxis_I:xaxis,phnx_yaxis_I:yaxis}
		IF datatype(data_stc) EQ 'INT' THEN data_stc=newstc ELSE data_stc=join_struct(data_stc,newstc)		
	ENDIF
	;2) Phoenix-2 spg - Stokes V
	IF info_stc.phoenix_spg_V GT 0 THEN BEGIN
		tmp=rapp_get_spectrogram(info_stc.time_intv,xaxis=xaxis,yaxis=yaxis,/ELIM,/POL)
		newstc={phnx_spg_V:tmp,phnx_xaxis_V:xaxis,phnx_yaxis_V:yaxis}
		IF datatype(data_stc) EQ 'INT' THEN data_stc=newstc ELSE data_stc=join_struct(data_stc,newstc)		
	ENDIF
	;3) NRH lc (FOV)
	;compute them from the brightest pixel in each of the maps that will be used.
	nrhtimes0='bla'
	nrhlc0='bla'
	nrhtimes1='bla'
	nrhlc1='bla'
	nrhtimes2='bla'
	nrhlc2='bla'
	nrhtimes3='bla'
	nrhlc3='bla'
	nrhtimes4='bla'
	nrhlc4='bla'

	;164MHz
		FOR i=0,N_ELEMENTS(info_stc.time_intvs)-2 DO BEGIN
			map=ethz_movie_return_nrh_map([info_stc.time_intvs[i],info_stc.time_intvs[i+1]], 0,info_stc.data_dir)
			IF datatype(map) EQ 'STC' THEN IF datatype(nrhtimes) EQ 'STR' THEN BEGIN
								nrhtimes0=anytim(map.time) 
								nrhlc0=MAX(map.data)
							ENDIF ELSE BEGIN
								nrhtimes0=[nrhtimes0,anytim(map.time)]
								nrhlc0=[[nrhlc0],[MAX(map.data)]]
							ENDELSE
		ENDFOR
		IF datatype(nrhtimes0) NE 'STR' THEN BEGIN
			data_stc=join_struct(data_stc,nrhtimes0)
			data_stc=join_struct(data_stc,nrhlc0)
		ENDIF
	;236MHz
		FOR i=0,N_ELEMENTS(info_stc.time_intvs)-2 DO BEGIN
			map=ethz_movie_return_nrh_map([info_stc.time_intvs[i],info_stc.time_intvs[i+1]], 1,info_stc.data_dir)
			IF datatype(map) EQ 'STC' THEN IF datatype(nrhtimes) EQ 'STR' THEN BEGIN
								nrhtimes1=anytim(map.time) 
								nrhlc1=MAX(map.data)
							ENDIF ELSE BEGIN
								nrhtimes1=[nrhtimes1,anytim(map.time)]
								nrhlc1=[[nrhlc1],[MAX(map.data)]]
							ENDELSE
		ENDFOR
		IF datatype(nrhtimes1) NE 'STR' THEN BEGIN
			data_stc=join_struct(data_stc,nrhtimes1)
			data_stc=join_struct(data_stc,nrhlc1)
		ENDIF
	;327MHz
		FOR i=0,N_ELEMENTS(info_stc.time_intvs)-2 DO BEGIN
			map=ethz_movie_return_nrh_map([info_stc.time_intvs[i],info_stc.time_intvs[i+1]], 2,info_stc.data_dir)
			IF datatype(map) EQ 'STC' THEN IF datatype(nrhtimes) EQ 'STR' THEN BEGIN
								nrhtimes2=anytim(map.time) 
								nrhlc2=MAX(map.data)
							ENDIF ELSE BEGIN
								nrhtimes2=[nrhtimes2,anytim(map.time)]
								nrhlc2=[[nrhlc2],[MAX(map.data)]]
							ENDELSE
		ENDFOR
		IF datatype(nrhtimes2) NE 'STR' THEN BEGIN
			data_stc=join_struct(data_stc,nrhtimes2)
			data_stc=join_struct(data_stc,nrhlc2)
		ENDIF
	;410MHz
		FOR i=0,N_ELEMENTS(info_stc.time_intvs)-2 DO BEGIN
			map=ethz_movie_return_nrh_map([info_stc.time_intvs[i],info_stc.time_intvs[i+1]], 3,info_stc.data_dir)
			IF datatype(map) EQ 'STC' THEN IF datatype(nrhtimes) EQ 'STR' THEN BEGIN
								nrhtimes3=anytim(map.time) 
								nrhlc3=MAX(map.data)
							ENDIF ELSE BEGIN
								nrhtimes3=[nrhtimes3,anytim(map.time)]
								nrhlc3=[[nrhlc3],[MAX(map.data)]]
							ENDELSE
		ENDFOR
		IF datatype(nrhtimes3) NE 'STR' THEN BEGIN
			data_stc=join_struct(data_stc,nrhtimes3)
			data_stc=join_struct(data_stc,nrhlc3)
		ENDIF
	;432MHz
		FOR i=0,N_ELEMENTS(info_stc.time_intvs)-2 DO BEGIN
			map=ethz_movie_return_nrh_map([info_stc.time_intvs[i],info_stc.time_intvs[i+1]], 4,info_stc.data_dir)
			IF datatype(map) EQ 'STC' THEN IF datatype(nrhtimes) EQ 'STR' THEN BEGIN
								nrhtimes4=anytim(map.time) 
								nrhlc4=MAX(map.data)
							ENDIF ELSE BEGIN
								nrhtimes4=[nrhtimes4,anytim(map.time)]
								nrhlc4=[[nrhlc4],[MAX(map.data)]]
							ENDELSE
		ENDFOR
		IF datatype(nrhtimes4) NE 'STR' THEN BEGIN
			data_stc=join_struct(data_stc,nrhtimes4)
			data_stc=join_struct(data_stc,nrhlc4)
		ENDIF

	;4) TRACE lc (FOV ?)
	
	;5) EIT lc (FOV ?)

	;6) GOES lc : no need to load in advance: will use plot_goes.pro all the way...
	;7) HESSI lc: will use Obs. Summary CORRECTED rates: can also be plotted on the spot...
	;8) HESSI spg

END
;================================================================================================================================================



;================================================================================================================================================
;================================================================================================================================================
PRO ethz_movie,	time_intv, data_dir,	$
	;input keywords
		xyoffset=xyoffset,	$	; default is given by HESSI
		fov=fov,		$	; default is 256"x256"
		deltat=deltat,		$	; default is 10 seconds
		outputsize=outputsize,	$	; default is [1024,512]
		js=js,			$	; default is ...
		KEEP=KEEP,		$	; if set, will keep all downloaded data instead of erasing them after use (the default)
		trace_trans=trace_trans,	$
		eit_trans=eit_trans,		$
		hessi_trans=hessi_trans,	$
		nrh_trans=nrh_trans,		$
		min_hsi_countrates=min_hsi_countrates,	$	;under this, HESSI images will be discarded (corrected countrates)
		min_nrh_tb=min_nrh_tb,			$	;if the NRH map's brightest pixel is under this value, don't map NRH.
	;output keywords
		movie=movie
		
;--------------
;Initialization
;--------------
IF NOT KEYWORD_SET(fov) THEN fov=[256,256]
IF NOT KEYWORD_SET(deltat) THEN deltat=10
IF NOT KEYWORD_SET(outputsize) THEN outputsize=[1024,512]
IF NOT KEYWORD_SET(xyoffset) THEN xyoffset=ethz_movie_return_xyoffset(time_intv,data_dir)
IF NOT KEYWORD_SET(min_hsi_countrates) THEN min_hsi_countrates=[200,200,200,200,200,200]	; channels 3-12,12-25,25-50,50-100,100-300
IF NOT KEYWORD_SET(min_nrh_tb) THEN min_nrh_tb=[0.,0.,0.,0,0.]

myct3,ct=1
info_stc={	phoenix_spg_I:1,	$
		phoenix_spg_V:0,	$
		nrh_lc_I:1,		$
		nrh_img_I:1,		$
		nrh_lc_V:0,		$
		nrh_img_V:0,		$
		trace_lc:0,		$
		trace_img:1,		$
		eit_lc:0,		$
		eit_img:0,		$
		goes_lc:1,		$
		hessi_lc:1,		$
		hessi_img:1,		$
		hessi_spg:0,		$
;0 means not checked yet. <0 means not available, >0 means OK.		
		n_tprof:4,		$
		n_img:3,		$
		data_dir:data_dir,	$
		time_intv:time_intv}

;-------------------------------------
;make an array of desired time ranges.
;-------------------------------------
n_frames=CEIL((anytim(time_intv[1])-anytim(time_intv[0]))/FLOAT(deltat))
time_intvs=anytim(time_intv[0])+FINDGEN(n_frames+1)*deltat
info_stc=add_tag(info_stc,time_intvs,'time_intvs')
;-----------------------------------------------------------------------
; check availability of data, and download what is needed and available.
;-----------------------------------------------------------------------
;1) HESSI
;The check is through the obs. summary (faster!).
;	oso=hsi_obs_summary()
;	oso->set,obs_time_interval=time_intv
;	tmp=oso->getdata()
;	if tmp[0,0] NE -1 THEN info.hessi=1
;	OBJ_DESTROY,oso
;2) GOES
	;is now local, and always assumed OK.
;3) TRACE/EIT
;	ethz_get_trace_fits,time_intv,dir=data_dir,err=err
;	IF err EQ 0 THEN info.trace = 1
;4) NANCAY
;5) PHOENIX

;======================
;compute time profiles.
;======================
data_stc=-1
ethz_movie_compute_time_prof,info_stc,data_stc
movie=BYTARR(outputsize[0],outputsize[1],n_frames)
;===================
;START OF MAIN LOOP:
;===================
;each movie frame is done individually... hence, properly normalizing TRACE images will be a mess...
xmargin=[10,1]
ymargin=[1,1]
charsize=2.0
prevmainmap=-1
psh_win,outputsize[0],outputsize[1]
FOR i=0L,n_frames-1 DO BEGIN
	PRINT,'Doing frame : '+strn(i)	
	!P.MULTI=[0,2,info_stc.n_tprof,0,1]
	;----------------------------------------------------------
	;compute and display what must be computed and displayed...
	;----------------------------------------------------------

;TIME PROFILES
clear_utplot
;--------phoenix-2 Stokes I (if any)
	IF info_stc.phoenix_spg_I THEN BEGIN 
		rapp_plt_spg,data_stc.phnx_spg_I,data_stc.phnx_xaxis_I,data_stc.phnx_yaxis_I,/UT,xtit='',ytit='Phoenix-2 Stokes I/MHz',xmargin=xmargin,ymargin=ymargin,charsize=charsize
	ENDIF

;--------phoenix-2 Stokes V (if any)
	IF info_stc.phoenix_spg_V THEN BEGIN 
		rapp_plt_spg,data_stc.phnx_spg_V,data_stc.phnx_xaxis_V,data_stc.phnx_yaxis_V,/UT,xtit='',ytit='Phoenix-2 Stokes V/MHz',xmargin=xmargin,ymargin=ymargin,charsize=charsize
	ENDIF
;--------NRH lc (FOV)
	IF TAG_EXIST(data_stc,'nrhtimes0') THEN BEGIN		;problem: I assume if any exist, that 164 MHz it is...
		utplot,data_stc.nrhtimes0-data_stc.nrhtimes0[0],data_stc.nrhlc0,data_stc.nrhtimes0[0]
		IF TAG_EXIST(data_stc,'nrhtimes1') THEN BEGIN
			outplot,data_stc.nrhtimes1-data_stc.nrhtimes1[0],data_stc.nrhlc1,data_stc.nrhtimes1[0]
		ENDIF
		IF TAG_EXIST(data_stc,'nrhtimes2') THEN BEGIN
			outplot,data_stc.nrhtimes2-data_stc.nrhtimes2[0],data_stc.nrhlc2,data_stc.nrhtimes2[0]
		ENDIF
		IF TAG_EXIST(data_stc,'nrhtimes3') THEN BEGIN
			outplot,data_stc.nrhtimes3-data_stc.nrhtimes3[0],data_stc.nrhlc3,data_stc.nrhtimes3[0]
		ENDIF
		IF TAG_EXIST(data_stc,'nrhtimes4') THEN BEGIN
			outplot,data_stc.nrhtimes4-data_stc.nrhtimes4[0],data_stc.nrhlc4,data_stc.nrhtimes4[0]
		ENDIF
	ENDIF
;--------TRACE lc (FOV ?)

;--------EIT lc (FOV ?)

;--------GOES lc
	plot_goes,anytim(time_intv[0],/ECS),anytim(time_intv[1],/ECS),color=[249,252],/nodeftitle,xtitle='',ytitle='GOES-8 X-ray flux W/m!U2!N',xmargin=xmargin,ymargin=ymargin,charsize=charsize,thick=3,/three   
;--------HESSI lc: Obs. Summary CORRECTED rates
	rates=hessi_corrected_os_countrate(time_intv,time=times)
	utplot,times-times[0],TOTAL(rates[0:1,*],1),times[0],/YLOG,yrange=[1.,MAX(rates)],xstyle=1,xmargin=xmargin,ymargin=ymargin,charsize=charsize,ytit='RHESSI corrected cts/s/det',xtickname=REPLICATE(' ',10),color=249
	outplot,times-times[0],rates[2,*],color=250
	outplot,times-times[0],rates[4,*],color=251
	outplot,times-times[0],rates[5,*],color=252
	outplot,times-times[0],rates[6,*],color=254
;--------HESSI spg

;--------add interval marker
	tmp=CONVERT_COORD(/DATA,/TO_NORMAL,time_intvs[i]-times[0],0,/DOUBLE)
	PLOTS,[tmp[0],tmp[0]],[0,1.],/NORM
	tmp=CONVERT_COORD(/DATA,/TO_NORMAL,time_intvs[i+1]-times[0],0,/DOUBLE)
	PLOTS,[tmp[0],tmp[0]],[0,1.],/NORM

;IMAGES----------------------------
!P.MULTI=[1,2,1]
	;plot_image,dist(100)
;--------pick first TRACE image in proper time range
	newmap=ethz_movie_return_trace_map([time_intvs[i],time_intvs[i+1]],data_dir)
	IF datatype(newmap) NE 'STC' THEN mainmap=prevmainmap ELSE BEGIN
		mainmap=newmap
		prevmainmap=newmap
	ENDELSE
	plot_map,mainmap,trans=trace_trans,/LOG,xrange=xyoffset[0]+fov[0]*[-0.5,0.5],yrange=xyoffset[1]+fov[1]*[-0.5,0.5]
	
;--------oplot 4-sec RHESSI imgs: 3-12, 12-25, 25-50, 50-300 keV
	cmap=ethz_movie_return_hsi_map([time_intvs[i],time_intvs[i+1]],[3,12],xyoffset,min_hsi_countrates[0],os_eband=[0,1])
	IF datatype(cmap) NE 'INT' THEN plot_map,/over,cmap,trans=hessi_trans,lcolor=249,/percent,levels=[50,101],cthick=2
	cmap=ethz_movie_return_hsi_map([time_intvs[i],time_intvs[i+1]],[12,25],xyoffset,min_hsi_countrates[1],os_eband=2)
	IF datatype(cmap) NE 'INT' THEN plot_map,/over,cmap,trans=hessi_trans,lcolor=240,/percent,levels=[50,101],cthick=2
	cmap=ethz_movie_return_hsi_map([time_intvs[i],time_intvs[i+1]],[25,50],xyoffset,min_hsi_countrates[2],os_eband=3)
	IF datatype(cmap) NE 'INT' THEN plot_map,/over,cmap,trans=hessi_trans,lcolor=251,/percent,levels=[50,101],cthick=2
	cmap=ethz_movie_return_hsi_map([time_intvs[i],time_intvs[i+1]],[50,100],xyoffset,min_hsi_countrates[3],os_eband=4)
	IF datatype(cmap) NE 'INT' THEN plot_map,/over,cmap,trans=hessi_trans,lcolor=252,/percent,levels=[50,101],cthick=2
	cmap=ethz_movie_return_hsi_map([time_intvs[i],time_intvs[i+1]],[100,300],xyoffset,min_hsi_countrates[4],os_eband=5)
	IF datatype(cmap) NE 'INT' THEN plot_map,/over,cmap,trans=hessi_trans,lcolor=253,/percent,levels=[50,101],cthick=2	
;--------oplot first NRH images in time range (STOKES I)
	FOR f=0,4 DO BEGIN
		cmap=ethz_movie_return_nrh_map([time_intvs[i],time_intvs[i+1]], f,data_dir,min_tb=min_nrh_tb[f])
		IF datatype(cmap) NE 'INT' THEN plot_map,/over,cmap,trans=nrh_trans,/percent,levels=[30,60,90],lcolor=249+f
	ENDFOR
	;-----------------------
	;save it in movie array.
	;-----------------------
	movie[*,*,i]=TVRD()
ENDFOR
;=================
;END OF MAIN LOOP.
;=================

;=================
;END OF MAIN PROGRAM
;=================
END
;================================================================================================================================================
;================================================================================================================================================




