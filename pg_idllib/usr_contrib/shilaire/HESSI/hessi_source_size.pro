; Given a HESSI image object, with a single source in the FOV, determines the TRUE size of the source.
; Uses Ed's formula: A = Max * <gridtran> / counts  =  exp(-0.89*(sourcesize/collresolution)^2)
; There should be no dropouts !!!!!!!!!
;
; PSH 2002/10/24 created.
;
;
; Spin axis should be out of FOV, or at least not the brightest spot...
; If keyword /AUTO is set, it supersedes the coll keyword, and takes the best collimators (i.e. those that correlate better than 50% with the psf)
; We are supposed already more or less centered at the right place (or I have to do something about the call to the psf...).
;
;;
; EXAMPLE: 
;	0)
;	hessi_source_size,imo,/AUTO,fwhmvalue=fwhm	
;	print,fwhm
;
;
;	1) real data	
;	imo=hsi_image()
;	imo->set,time_range='2002/02/26 '+['10:26:43','10:26:56']	;~3x(spin period of 4.35s)
;	imo->set,pixel_size=1,image_dim=128,xyoffset=[925,-225]
;	imo->set,det_index=[0,0,1,1,1,1,1,1,0]
;	imo->plot
;	;hessi_source_size,imo,coll=[1,3,4,5,6,7,8,9],/LOUD	; colls numbered from 1 to 9 in procedure call. Internally, from 0 to 8.
;	hessi_source_size,imo,/AUTO,LOUD=2,fwhmvalue=fwhm,fwhmsigma=fwhmsigma
;	PRINT,fwhm,fwhmsigma
;
;
;	2) simulated data	(OLD VERSION)
;        hessi_version,/release
;        simo=hsi_image()
;        pixsiz=1.
;        imgdim=128
;        timeintv=12.
;        gg = {gaussian_source_str} 
;        gg.xypos = [0.,0.] 
;        gg.tilt_angle_deg = 0. 
;        gg.amplitude = 1.0 
;        ;================================================================
;        gg.xysigma = 5.0*[1.,1.]/2.355 
;        ;================================================================
;        simo ->set, sim_model=gg,sim_photons_per_coll=60000,            $
;                sim_pixel_size=pixsiz, pixel_size=pixsiz,               $
;                energy_band=[12.,25.] , sim_energy_band=[12.,25.],      $
;                det_index=1+BYTARR(9),sim_det_index=1B+BYTARR(9),       $
;                time_range=[0.,timeintv],sim_time_range=[0.,timeintv],  $
;                sim_image_dim=imgdim, image_dim=imgdim
;;;;;;;;;simo->set,sim_xyoffset=[-900,-100],xyoffset=[-900,-100]
;        simo->plot
;
;	hessi_source_size,simo,coll=[1,2,3,4,5,6,7,8,9],/LOUD
;
;
;	2a) simulated data	(NEW VERSION)
;	 hsi_switch,/sim
;        simo=hsi_image()
;        pixsiz=1.
;        imgdim=128
;        timeintv=12.
;        gg = {gaussian_source_str} 
;        gg.xypos = [0.,0.] 
;        gg.tilt_angle_deg = 0. 
;        gg.amplitude = 1.0 
;        ;================================================================
;        gg.xysigma = 5.0*[1.,1.]/2.355 
;        ;================================================================
;        simo ->set, sim_model=gg,sim_photons_per_coll=60000,            $
;                sim_pixel_size=pixsiz, pixel_size=pixsiz,               $
;                energy_band=[12.,25.] , sim_energy_band=[12.,25.],      $
;                det_index=1+BYTARR(9),sim_det_index=1B+BYTARR(9),       $
;                time_range=[0.,timeintv],sim_time_range=[0.,timeintv],  $
;                sim_image_dim=imgdim, image_dim=imgdim
;;;;;;;;;simo->set,sim_xyoffset=[-900,-100],xyoffset=[-900,-100]
;        simo->plot
;
;	hessi_source_size,simo,coll=[1,2,3,4,5,6,7,8,9],fwhm=fwhm
;	print,fwhm
;
;	hessi_source_size,simo,/AUTO,fwhmvalue=fwhm,fwhmsigma=fwhmsigma
;	print,fwhm,fwhmsigma
;
;
;
;;	3) simulated data: double gaussians	(OLD VERSION)
;        hessi_version,/release
;        simo=hsi_image()
;        pixsiz=1.
;        imgdim=128
;        timeintv=12.
;        gg1 = {gaussian_source_str} 
;        gg1.xypos = [0.,0.] 
;        gg1.tilt_angle_deg = 0. 
;        gg1.amplitude = 1.0 
;        gg2 = {gaussian_source_str} 
;        gg2.xypos = [0.,0.] 
;        gg2.tilt_angle_deg = 0. 
;        gg2.amplitude = 0.3 
;        ;================================================================
;        gg1.xysigma = 5.0*[1.,1.]/2.355 
;        gg2.xysigma = 40.0*[1.,1.]/2.355 
;        ;================================================================
;	model=[gg1,gg2]
;        simo ->set, sim_model=model,sim_photons_per_coll=60000,            $
;                sim_pixel_size=pixsiz, pixel_size=pixsiz,               $
;                energy_band=[12.,25.] , sim_energy_band=[12.,25.],      $
;                det_index=1+BYTARR(9),sim_det_index=1+BYTARR(9),        $
;                time_range=[0.,timeintv],sim_time_range=[0.,timeintv],  $
;                sim_image_dim=imgdim, image_dim=imgdim
;        simo->plot
;
;	hessi_source_size,simo,coll=[1,2,3,4,5,6,7,8,9],/LOUD
;
;

PRO hessi_source_size,imo,coll=coll,LOUD=LOUD,NOMEAN=NOMEAN,truesize=truesize, fwhmvalue=truefwhm, fwhmSigma= truefwhmSigma, AUTO=AUTO

IF NOT KEYWORD_SET(LOUD) THEN LOUD=0
IF NOT EXIST(coll) THEN coll=BINDGEN(9) ELSE coll=coll-1
IF KEYWORD_SET(AUTO) THEN coll=BINDGEN(9)

detres=[2.26,3.92,6.79,11.76,20.36,35.27,61.08,105.8,183.2]
bestcorr=FLTARR(9)

imo->set,image_alg='back projection'
imo->set_no_screen_output

A=FLTARR(9)
IF LOUD GE 2 THEN BEGIN
	psh_win,900
	!P.MULTI=[0,3,3]
ENDIF
FOR i=0,N_ELEMENTS(coll)-1 DO BEGIN	;loop through all chosen collimators to get A for each.
	IF KEYWORD_SET(LOUD) THEN PRINT,'Collimator: '+strn(coll[i]+1)
	;get peakvalue
		det_index=BYTARR(9)
		det_index[coll[i]]=1B
		;choose FOV appropriate for this subcollimator
	;	CASE coll[i] OF
	;		0: BEGIN & pixel_size=1 & image_dim=16 & END
	;		1: BEGIN & pixel_size=1 & image_dim=16 & END
	;		2: BEGIN & pixel_size=1 & image_dim=16 & END
	;		3: BEGIN & pixel_size=1 & image_dim=32 & END
	;		4: BEGIN & pixel_size=1 & image_dim=64 & END
	;		5: BEGIN & pixel_size=1 & image_dim=128 & END
	;		6: BEGIN & pixel_size=4 & image_dim=64 & END
	;		7: BEGIN & pixel_size=4 & image_dim=64 & END
	;		8: BEGIN & pixel_size=4 & image_dim=128 & END
	;		ELSE: BEGIN & pixel_size=1 & image_dim=128 & END 
	;	ENDCASE	
	;	imo->set,image_dim=image_dim,pixel_size=pixel_size
	imo->set,image_dim=128,pixel_size=1
		imo->set,det_index=det_index
		IF LOUD GE 2 THEN imo->plot,label_size=1.0,title='',mar=0.001,charsize=2.0
		tmp=imo->getdata()
		peakvalue=MAX(tmp)
	;get best correlation with psf...
	IF KEYWORD_SET(AUTO) THEN BEGIN
		annsec_psf=imo->getdata(class='hsi_psf',xy_pixel=[64,64],det_index=det_index)
		xy_psf=hsi_annsec2xy(annsec_psf,imo)
		bestcorr[i]=MAX( CROSS_CORR2( tmp, xy_psf, 5, COUNT=LOUD) )
		PRINT,'Best correlation for collimator '+strn(i+1)+' :  '+strn(100*bestcorr[i],format='(f10.1)')+'%'
	ENDIF
	;get counts
		tmp=imo->get(/binned_n_event)
		counts=tmp[coll[i],0]
	;get gridtran
		cbe=imo->GetData( CLASS_NAME = 'HSI_Calib_eventlist' )
		;P_m=MEAN((*cbe[coll[i],0]).GRIDTRAN)
		P_m=MEAN( (*cbe[coll[i],0]).gridtran*(1.+(*cbe[coll[i],0]).modamp*cos((*cbe[coll[i],0]).phase_map_ctr)))
		IF KEYWORD_SET(LOUD) THEN PRINT,'Gridtran: '+strn(P_m)+' +/- '+strn(STDDEV((*cbe[coll[i],0]).GRIDTRAN))
	;determine A
		A[coll[i]]=peakvalue*P_m/counts
	
		theoretical_peakvalue=1.0*counts/P_m
		PRINT,'Expected peak value (single point source) = '+strn(theoretical_peakvalue)
		PRINT,'Peakvalue = '+strn(peakvalue)
	
		IF KEYWORD_SET(NOMEAN) THEN BEGIN
			;get counts (corrected for livetime) and gridtran for each time bin...
			realctsovergridtran=0
			FOR j=0,N_ELEMENTS((*cbe[coll[i],0]))-1 DO BEGIN
				IF (*cbe[coll[i],0])[j].LIVETIME NE 0 THEN realctsovergridtran=realctsovergridtran + (*cbe[coll[i],0])[j].COUNT/(*cbe[coll[i],0])[j].LIVETIME/(*cbe[coll[i],0])[j].GRIDTRAN
			ENDFOR
			A[coll[i]]=peakvalue/realctsovergridtran
		ENDIF
		IF KEYWORD_SET(LOUD) THEN PRINT,'Relative amplitude: '+strn(A[coll[i]])+', would mean true source FWHM= '+strn(sqrt(-alog(A[coll[i]])/0.89*detres[coll[i]]^2))+'".'
	
	;determine the percentage of dropouts (just to have a figure...)
		ss=WHERE((*cbe[coll[i],0]).LIVETIME EQ 0)
		IF ss[0] EQ -1 THEN nbrdropouts=0 ELSE nbrdropouts=N_ELEMENTS(ss)
		nbrbins=N_ELEMENTS(*cbe[coll[i],0])
		IF KEYWORD_SET(LOUD) THEN PRINT,'Dropouts '+strn(100.*nbrdropouts/nbrbins)+'% of the time.'
ENDFOR

IF KEYWORD_SET(AUTO) THEN BEGIN
	PRINT,'........taking only collimator images which are more than 50% correlated with their psf:'
	coll=WHERE(bestcorr GE 0.5)
	PRINT,detres[coll]
ENDIF

res=LINFIT(1/(detres[coll])^2,alog(A[coll]),CHISQ=chisq,PROB=prob,SIGMA=sigma,YFIT=yfit)
trueFWHM=sqrt(-res[1]/0.89)
trueFWHMSigma=sqrt(sigma[1]/0.89)

IF KEYWORD_SET(LOUD) THEN BEGIN
	WINDOW,xs=512,ys=512,/FREE
	!P.MULTI=[0,1,2]
	info=imo->get()
	tit='Energy band: '+strn(info.ENERGY_BAND[0])+'-'+strn(info.ENERGY_BAND[1])+' keV. Map center: ('+strn(info.xyoffset[0],format='(f6.1)')+','+strn(info.xyoffset[1],format='(f6.1)')+').'
	IF KEYWORD_SET(truesize) THEN tit=tit+' True size: '+strn(truesize,FORMAT='(f9.4)')+'".'
	PLOT,1/detres[coll],A[coll],psym=7,xtit='1/Collimator resolution',ytit='Relative amplitude A',tit=tit
	IF KEYWORD_SET(truesize) THEN OPLOT,1/detres[coll],exp(-0.89*(truesize/detres[coll])^2),linestyle=1
	OPLOT,1/detres[coll],exp(yfit)

	PLOT,1/(detres[coll])^2,A[coll],psym=7,/YLOG,xtit='1/res!U2!N',ytit='A',yrange=[0.1,1.5],ystyle=1
	OPLOT,1/(detres[coll])^2,exp(yfit)
	IF KEYWORD_SET(truesize) THEN OPLOT,1/(detres[coll])^2,exp(-0.89*(truesize/detres[coll])^2),linestyle=1

	XYOUTS,/NORM,0.58,0.43,'From fit:'
	thetext='Source FWHM: '+strn(trueFWHM,format='(f8.2)')+'" +/- '+strn(trueFWHMSigma,format='(f8.2)')+'"'
	XYOUTS,/NORM,0.58,0.4,thetext
	thetext='Intercept point: '+strn(exp(res[0]),format='(f8.2)')+' +/- '+strn(sigma[0],format='(f8.2)')
	XYOUTS,/NORM,0.58,0.37,thetext
	!P.MULTI=0
ENDIF

PRINT,'................................................................................................'
PRINT,'Result of linear fitting:....................'
PRINT,'............ . source FWHM: '+strn(trueFWHM)+'" +/- '+strn(sqrt(sigma[1]/0.89))+'".'
IF KEYWORD_SET(LOUD) THEN PRINT,'PROB: '+strn(prob)
IF KEYWORD_SET(LOUD) THEN PRINT,'CHI-SQ: '+strn(chisq)
END


