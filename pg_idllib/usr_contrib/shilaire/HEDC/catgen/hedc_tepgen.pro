; V5
;
; time-energy panel (of images) generator
;
; if time_intvs are given (keyword), will disregard flare_intv and pick those times for imaging intvs. Otherwise looks for its own...
;
; EXAMPLES:
;	hedc_tepgen, '2002/02/26 '+['10:26','10:29'],[925,-225],imgalg='back',time_intvs='2002/02/26 '+['10:26:30','10:27:00']	
;	hedc_tepgen, '2002/02/26 '+['10:26','10:29'],[925,-225],imgalg='back'	
;	hedc_tepgen, '2002/02/26 '+['10:26','10:29'],[925,-225],newdatadir=newdatadir,eventcode=eventcode,ev_struct=ev_struct,eventtype=eventtype
;	hedc_tepgen, '2002/02/26 '+['10:26','10:29'],[925,-225],imspecfile='hsi_imagetesseract.fits'
;	
;	hedc_tepgen, '2002/02/20 '+['11:04','11:07'],[907,261],imgalg='back'
;
; PSH 2003/02/27: Version 2 (plots LIMB and GRID: needed somewhat important internal changes)
; PSH 2003/06/11: removed /PARTICLES keyword in call to to_nice_img_intervals.pro, as the particle flag is really unusable now...
; PSH 2003/08/04: added output keyword 'imagetesseract'
; PSH 2003/08/29: now outputs proper RHESSI imagecube fitsfile
; PSH 2003/09/08: V3:added keyword imspecfile (a filename for HESSI imagetesseract fitsfile): setting this keyword will do a lot more processing!
; PSH 2004/01/27: V4: this routine now also works if the HEDC-needed keywords are not specified.
; PSH 2005/02/21: V5: this routine now uses Andre's multi image software. Individual image fits files no longer saved...
;
;--------------------------------------------------------------------------------------------------------------------------------------------------
PRO hedc_tepgen_img_plot, basesize, data, info, binned_n_event

	charsize=0.8
	lowerleft=[2,2]
	upperleft=[2,basesize-12]
	
	;map =  make_map( data, $
        ;         xc=info.xyoffset[0], $
        ;         yc=info.xyoffset[1], $
        ;         dx=info.pixel_size[0], $
        ;         dy=info.pixel_size[1], $
        ;         time=anytim(0,/tai) )
	map=make_hsi_map(data,info)			

	drange=[-1.,1.]*MAX([abs(MAX(map.data)),abs(MIN(map.data))])
	plot_map,map,grid=10,charsize=charsize,/LIMB,xtickname=REPLICATE(' ',10),ytickname=REPLICATE(' ',10),xtit='',ytit='',tit='',ticklen=0,mar=0.001,drange=drange

	n_event = binned_n_event

	text = hsi_coll_segment_list(info.det_index_mask, REFORM(info.a2d_index_mask, 9, 3), info.front_segment, info.rear_segment, colls_used=colls_used)
	XYOUTS,upperleft[0],upperleft[1],/DEVICE,text, charsize=charsize
	
	total_events = strupcase (strtrim (string(total(n_event[where(colls_used),0]), format='(g12.3)'),2))
	total_events = 'Total counts: ' + str_replace (total_events, 'E+00', 'E+0')
	text=total_events 
	XYOUTS,lowerleft[0],lowerleft[1],/DEVICE,text, charsize=charsize
END
;--------------------------------------------------------------------------------------------------------------------------------------------------
PRO hedc_tepgen, flare_intv, xyoffset, time_intvs=time_intvs,								$
	deltat=deltat,imgalg=imgalg,detindex=detindex,pixsize=pixsize,imgdim=imgdim,ebands=ebands,pictype=pictype,	$
	imagetesseract=imagetesseract,											$ 	;OPTIONAL OUTPUT
	newdatadir=newdatadir,eventcode=eventcode,ev_struct=ev_struct,eventtype=eventtype		;needed keywords for writing HEDC stuff...
	
	PRINT,'...................hedc_tepgen V5.....................'

;initialization phase:
	IF NOT KEYWORD_SET(newdatadir) THEN newdatadir=GETENV('HOME')+'/'
	IF NOT KEYWORD_SET(deltat) THEN deltat=60. ELSE deltat=FLOAT(deltat)
	IF NOT KEYWORD_SET(imgalg) THEN imgalg='clean'
	IF NOT KEYWORD_SET(detindex) THEN detindex=[0,0,1,1,1,1,1,1,0]
	IF NOT KEYWORD_SET(pixsize) THEN pixsize=1
	IF NOT KEYWORD_SET(imgdim) THEN imgdim=128
	IF NOT KEYWORD_SET(ebands) THEN ebands=[[4,6],[6,8],[12,25],[25,50],[50,100],[100,300]]
	IF NOT KEYWORD_SET(pictype) THEN pictype='png'
	IF NOT KEYWORD_SET(eventcode) THEN eventcode='TEST'
	IF NOT KEYWORD_SET(eventtype) THEN eventtype='isp'	
	IF NOT KEYWORD_SET(ev_struct) THEN ev_struct={EVENT_CODE:'Z', EVENT_TYPE:'Z', SIMULATED:'Z', MIN_ENERGY_FOUND:ebands[0,0], MAX_ENERGY_FOUND:ebands[1,N_ELEMENTS(ebands[1,*])-1], EVENT_ID_NUMBER:'Z'}

;local variables:
	basesize=150
	n_ebands=N_ELEMENTS(ebands[0,*])
	
	IF KEYWORD_SET(time_intvs) THEN t_intvs=time_intvs ELSE BEGIN
		t_intvs=-1
		good_img_intvs=to_nice_img_intervals(flare_intv,mindeltat=deltat/2.,/ATTLOW,wait_after_shutter=60.,wait_after_eclipse=120.)
			;good_img_intvs=to_nice_img_intervals(flare_intv,mindeltat=deltat/2.,/ATTLOW,/PARTICLES,wait_after_shutter=60.,wait_after_eclipse=120.)
		IF N_ELEMENTS(good_img_intvs) THEN MESSAGE,'.......NO GOOD TIME INTV FOUND!'
		good_img_intvs=anytim(good_img_intvs)
		FOR i=0,N_ELEMENTS(good_img_intvs[0,*])-1 DO BEGIN
			duration=good_img_intvs[1,i]-good_img_intvs[0,i]
			n=duration/deltat	;n is a double
			WHILE n GE 1. DO BEGIN
				IF N_ELEMENTS(t_intvs) EQ 1 THEN t_intvs=good_img_intvs[1,i]-[n,n-1]*deltat ELSE t_intvs=[[t_intvs],[good_img_intvs[1,i]-[n,n-1]*deltat]]			
				n=n-1.
			ENDWHILE
			IF n GE 0.5 THEN IF N_ELEMENTS(t_intvs) EQ 1 THEN t_intvs=good_img_intvs[1,i]-[n,0]*deltat ELSE t_intvs=[[t_intvs],[good_img_intvs[1,i]-[n,0]*deltat]]			
		ENDFOR
		IF N_ELEMENTS(t_intvs) EQ 1 THEN t_intvs=good_img_intvs
	ENDELSE
	
	n_intvs=N_ELEMENTS(t_intvs[0,*])
	
	overallfilename=newdatadir+'HEDC_DP_pten_'+eventcode
	fitsfile=overallfilename+'.fits'

;processing	
	imo=hsi_image()	
	imo->set,im_time_int=t_intvs
	imo->set,im_energy_bin=ebands
	imo->set,image_alg=imgalg
	imo->set,pixel_size=pixsize,image_dim=imgdim,xyoffset=xyoffset
	imo->set,det_index_mask=detindex
	imo->set_no_screen_output
	imo->set,verbose=1
	imo->fitswrite, this_out_file=fitsfile
	bla=imo->getdata()	

;start graphic stuff
	imgs=FLTARR(basesize,basesize,n_ebands,n_intvs)
	imagetesseract=mrdfits(fitsfile,0)

	FOR i=0L,n_intvs-1 DO BEGIN
		FOR j=0,n_ebands-1 DO BEGIN
			eband=ebands[*,j]
			hedc_win,basesize
			hedc_tepgen_img_plot, basesize, imagetesseract[*,*,j,i], mrdfits(fitsfile,1),(mrdfits(fitsfile,i*n_ebands+j+2)).binned_n_event
			imgs[*,*,j,i]=TVRD()
		ENDFOR	
	ENDFOR
	
	;all images have been calculated,
	;make a panel of all those images...
	
	addxsize=30
	addysize=20
	xsize=basesize*n_intvs+addxsize
	ysize=basesize*n_ebands+addysize
	hedc_win,xsize,ysize
	hessi_ct,/QUICK
	TVLCT,r,g,b,/GET
	!P.MULTI=[0,n_intvs,n_ebands]
	FOR j=0,n_ebands-1 DO BEGIN
		FOR i=0,n_intvs-1 DO BEGIN
			TV,imgs[*,*,j,i],addxsize+i*basesize,(n_ebands-1-j)*basesize
		ENDFOR
	ENDFOR

	FOR j=0,n_ebands-1 DO BEGIN
		ligne=strn(ebands[0,n_ebands-j-1])+'-'+strn(ebands[1,n_ebands-j-1])+' keV'
		XYOUTS,/DEV,addxsize-5,40+basesize*j,charsize=0.8,ORIENTATION=90,ligne		
	ENDFOR
	FOR i=0,n_intvs-1 DO BEGIN 
		XYOUTS,/DEV,addxsize+i*basesize+10,ysize-10,anytim(t_intvs[0,i],/ECS,/time_only)+ ' to'
		XYOUTS,/DEV,addxsize+i*basesize+10,ysize-20,anytim(t_intvs[1,i],/ECS,/time_only)		
	ENDFOR

	info=imo->get()
	text='  Time vs. Energy panel   --   DATE: '+anytim(info.obs_time_interval[0],/date,/ECS)+'   Imaging algorithm: '+info.image_algorithm
	text=text+'   XYOFFSET=['+strn(info.xyoffset[0],format='(f7.1)')+' , '+strn(info.xyoffset[1],format='(f7.1)')+']'
	text=text+'   FOV: '+strn(FIX(info.pixel_size[0]*info.image_dim[0]))+'"x'+strn(FIX(info.pixel_size[1]*info.image_dim[1]))+'"'
	XYOUTS,10,10,/DEV,text,ORIENTATION=90
	
	IF KEYWORD_SET(newdatadir) THEN BEGIN
		CALL_PROCEDURE,'write_'+pictype,overallfilename+'.'+pictype,TVRD(),r,g,b
		info=imo->get()
		info.ABSOLUTE_TIME_RANGE=anytim(flare_intv)
		info.ENERGY_BAND=[ebands[0,0],ebands[1,n_ebands-1]]
		IF FILE_EXIST(overallfilename+'.'+pictype) THEN hedc_write_info_file,'ptn',ev_struct,info,overallfilename+'.info'
	ENDIF

IF KEYWORD_SET(STAMP) THEN timestamp, /bottom, charsize=0.5
PRINT,'...............hedc_tepgen.pro FINISHED without crashes!!'
END

