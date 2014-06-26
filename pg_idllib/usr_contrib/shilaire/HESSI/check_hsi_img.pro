
;EXAMPLE:
; see at the end.


; fileroot must be used if /PS is set.


PRO check_hsi_img,imo,GAUSSFIT=GAUSSFIT,fileroot=fileroot,charsize=charsize,NORECOMPUTE=NORECOMPUTE, NOAUTO=NOAUTO, $
		be=be,fitstuff=fitstuff,PS=PS,Cmax=Cmax,Cmin=Cmin,SMOOTHING=SMOOTHING
		
	
	IF KEYWORD_SET(SMOOTHING) THEN IF SMOOTHING EQ 1 THEN SMOOTHING=3
	IF NOT KEYWORD_SET(charsize) THEN charsize=1.2
	IF KEYWORD_SET(GAUSSFIT) THEN fitstuff=REPLICATE({A0:-9999.,A1:-9999.,a:-9999.,b:-9999.,x:-9999.,y:-9999.,tilt:-9999.},9) ELSE fitstuff=-1
	
	;absolutes:
	detres=[2.3,3.9,6.9,11.9,20.7,35.9,62.1,107.,186.]
	harmonic=0
	
	info=imo->get()
	
	;almost absolutes:
	;timebins=FLOAT([1,1,2,4,8,8,16,32,64])/1000.
	timebins=info.TIME_BIN_DEF/1000.
	
	;==================================================
	;	BACK PROJ. images, sc by sc	
	;==================================================
IF NOT KEYWORD_SET(NORECOMPUTE) THEN BEGIN
	hedc_win,900,nb=1
	!P.MULTI=[0,3,3]
	hessi_ct
	TVLCT,r,g,b,/GET
	FOR coll=0,8 DO BEGIN
		es=0
		CATCH,es
		IF es NE 0 THEN BEGIN
			es=0
			GOTO,NEXTPLEASE
		ENDIF
		
		det_index=BYTARR(9)
		det_index(coll)=1		
		pixsiz=detres[coll]/50. * [1.,1.]

		imo->set,det_index=det_index,pixel_size=pixsiz
		imo->set_no_screen_output
		im=imo->getdata()		
		imo->plot,charsize=charsize,top=240,/LIMB,xtit='',ytit='',tit='',mar=0.02
		
		IF KEYWORD_SET(GAUSSFIT) THEN BEGIN
			tmp=gauss2dfit(im,a,/TILT)
			fitstuff[coll].A0=a[0]		; offset constant
			fitstuff[coll].A1=a[1]		; scaling (proportional to photon flux)
			fitstuff[coll].a=a[2]*info.pixel_size[0]	; "semi-major"
			fitstuff[coll].b=a[3]*info.pixel_size[1]	; "semi-minor"
			fitstuff[coll].x=(a[4]-info.image_dim[0]/2)*info.pixel_size[0] + info.xyoffset[0]
			fitstuff[coll].y=(a[5]-info.image_dim[1]/2)*info.pixel_size[1] + info.xyoffset[1]
			fitstuff[coll].tilt=a[6]	; radians, counterclockwise from x-axis
			fitmap=make_map(tmp,XC=info.xyoffset[0],YC=info.xyoffset[1],DX=info.pixel_size[0],DY=info.pixel_size[1])
			plot_map,/OVER,fitmap,lcolor=252,cthick=2,/percent,levels=[25,50,75]
		ENDIF
		
		NEXTPLEASE:
		CATCH,/CANCEL
	ENDFOR
	IF KEYWORD_SET(fileroot) THEN WRITE_PNG,fileroot+'_img.png',TVRD(),r,g,b		
ENDIF	
	;==================================================
	;	get binned event list	
	;==================================================	
IF NOT KEYWORD_SET(NORECOMPUTE) THEN BEGIN
	be= imo -> getdata(class_name='hsi_binned_eventlist')
ENDIF
	;==================================================	


	;==================================================
	;	PLOT mod. profiles	
	;==================================================
	hedc_win,900,nb=2
	!P.MULTI=[0,1,9]
	;myct3,ct=1
	TVLCT,r,g,b,/GET
	
	Cmax=FLTARR(9)
	Cmin=FLTARR(9)
	Cmean=FLTARR(9)
	Cstddev=FLTARR(9)

	IF KEYWORD_SET(PS) THEN BEGIN
		SET_PLOT,'PS'
		DEVICE,filename=fileroot+'_modprof.ps'
	ENDIF
	
	FOR coll=0,8 DO BEGIN
		times=(*be[coll,harmonic]).time /(2.^20.)
		counts=(*be[coll,harmonic]).count
		IF KEYWORD_SET(SMOOTHING) THEN counts=SMOOTH(counts,SMOOTHING,/EDGE)
	
		PLOT, times, counts,charsize=1.3*charsize,ymar=[1,1],xstyle=1	;,ytit='counts'

		Cmax[coll]=MAX(counts)
		xmax=times[N_ELEMENTS(times)-1]
		ymax=Cmax[coll]
		IF NOT KEYWORD_SET(PS) THEN XYOUTS,/DATA,0.8*xmax,0.8*ymax,'Max: '+strn(Cmax[coll]),charsize=charsize,color=250
	
		Cmin[coll]=MIN(counts)
		IF NOT KEYWORD_SET(PS) THEN XYOUTS,/DATA,0.8*xmax,0.6*ymax,'Min: '+strn(Cmin[coll]),charsize=charsize,color=250

		Cmean[coll]=MEAN(counts)
		IF NOT KEYWORD_SET(PS) THEN XYOUTS,/DATA,0.8*xmax,0.4*ymax,'Mean: '+strn(Cmean[coll]),charsize=charsize,color=2

		Cstddev[coll]=STDDEV(counts)
		IF NOT KEYWORD_SET(PS) THEN XYOUTS,/DATA,0.8*xmax,0.2*ymax,'StdDev: '+strn(Cstddev[coll]),charsize=charsize,color=2
	ENDFOR
	
	IF KEYWORD_SET(fileroot) THEN BEGIN
		IF KEYWORD_SET(PS) THEN BEGIN
			DEVICE,/CLOSE
			SET_PLOT,'X'
		ENDIF ELSE BEGIN
			WRITE_PNG,fileroot+'_modprof.png',TVRD(),r,g,b		
		ENDELSE
	ENDIF
		
IF NOT KEYWORD_SET(NOAUTO) THEN BEGIN
	;==================================================
	;	PLOT autocorrelations
	;==================================================
	hedc_win,900,nb=3
	!P.MULTI=[0,1,9]
	;myct3,ct=1
	TVLCT,r,g,b,/GET

	IF KEYWORD_SET(PS) THEN BEGIN
		SET_PLOT,'PS'
		DEVICE,filename=fileroot+'_autocorr.ps'
	ENDIF

	FOR coll=0,8 DO BEGIN
		counts=(*be[coll,harmonic]).count
		IF KEYWORD_SET(SMOOTHING) THEN counts=SMOOTH(counts,SMOOTHING,/EDGE)
	
		n=N_ELEMENTS(counts)
		lags=L64INDGEN(2*n-3)-n+2
		coeff=A_CORRELATE(counts,lags,/DOUBLE)

		PLOT, lags, coeff,charsize=1.3*charsize,ymar=[1,1],yrange=[-1.,1.],xstyle=1
	ENDFOR
	
	IF KEYWORD_SET(fileroot) THEN BEGIN
		IF KEYWORD_SET(PS) THEN BEGIN
			DEVICE,/CLOSE
			SET_PLOT,'X'
		ENDIF ELSE BEGIN
			WRITE_PNG,fileroot+'_autocorr.png',TVRD(),r,g,b			
		ENDELSE
	ENDIF
ENDIF
	
	;==================================================
	;	PLOT FFT 	
	;==================================================
	hedc_win,900,nb=4
	!P.MULTI=[0,1,9]
	;myct3,ct=1
	TVLCT,r,g,b,/GET

	IF KEYWORD_SET(PS) THEN BEGIN
		SET_PLOT,'PS'
		DEVICE,filename=fileroot+'_fft.ps'
	ENDIF

	FOR coll=0,8 DO BEGIN
		times=(*be[coll,harmonic]).time /(2.^20.)
		nbins=N_ELEMENTS(times)
		counts=(*be[coll,harmonic]).count
		IF KEYWORD_SET(SMOOTHING) THEN counts=SMOOTH(counts,SMOOTHING,/EDGE)
		
		xarray=FINDGEN(nbins)/(times[nbins-1]-times[0])
		PLOT,xarray,abs(FFT(counts-MEAN(counts))),charsize=1.3*charsize,ymar=[1,1],xstyle=1	;,xtit='Hz'	;,ytit='FFT'
	ENDFOR

	IF KEYWORD_SET(fileroot) THEN BEGIN
		IF KEYWORD_SET(PS) THEN BEGIN
			DEVICE,/CLOSE
			SET_PLOT,'X'
		ENDIF ELSE BEGIN
			WRITE_PNG,fileroot+'_fft.png',TVRD(),r,g,b			
		ENDELSE
	ENDIF
	
	;==================================================
	;	PLOT relative amplitude
	;==================================================
	hedc_win,768,512,nb=5
	!P.MULTI=0
	;myct3,ct=1
	TVLCT,r,g,b,/GET

	IF KEYWORD_SET(PS) THEN BEGIN
		SET_PLOT,'PS'
		DEVICE,filename=fileroot+'_modflux.ps'
	ENDIF

	PLOT,detres,(Cmax-Cmin)/(Cmax+Cmin),/XLOG,xtit='detector resolution ["]',ytit='Relative amplitude: (Cmax-Cmin)/(Cmax+Cmin)',psym=-7,xstyle=1

	IF KEYWORD_SET(fileroot) THEN BEGIN
		IF KEYWORD_SET(PS) THEN BEGIN
			DEVICE,/CLOSE
			SET_PLOT,'X'
		ENDIF ELSE BEGIN
			WRITE_PNG,fileroot+'_modflux.png',TVRD(),r,g,b			
		ENDELSE
	ENDIF
	
	

	;==================================================
	;	PLOT 1/detres^2 vs. flux 	
	;==================================================
	IF KEYWORD_SET(GAUSSFIT) THEN BEGIN
		hedc_win,768,512,nb=6
		!P.MULTI=0
		;myct3,ct=1
		TVLCT,r,g,b,/GET

		IF KEYWORD_SET(PS) THEN BEGIN
			SET_PLOT,'PS'
			DEVICE,filename=fileroot+'_flux.ps'
		ENDIF


		PLOT,1/detres^2,fitstuff.A1,psym=-7,/YLOG,xstyle=1
	
		IF KEYWORD_SET(fileroot) THEN BEGIN
			IF KEYWORD_SET(PS) THEN BEGIN
				DEVICE,/CLOSE
				SET_PLOT,'X'
			ENDIF ELSE BEGIN
				WRITE_PNG,fileroot+'_flux.png',TVRD(),r,g,b			
			ENDELSE
		ENDIF
	ENDIF
	
END
;=========================;==========================================================;===========================================================================================
;=========================;==========================================================;===========================================================================================
;=========================;==========================================================;===========================================================================================









;=========================;==========================================================;===========================================================================================

;EXAMPLE:
	hessi_version,/release
	simo=hsi_image()
	pixsiz=1.
	imgdim=128
	timeintv=4.
	gg = {gaussian_source_str} 
	gg.xypos = [0.,0.] 
	gg.tilt_angle_deg = 0. 
	gg.amplitude = 1.0 
	;==========================================================
	gg.xysigma = 5.1*[1.,1.] 
	;==========================================================
	simo ->set, sim_model=gg,sim_photons_per_coll=500000,  		$
		sim_pixel_size=pixsiz, pixel_size=pixsiz, 		$
		energy_band=[12.,25.] ,	sim_energy_band=[12.,25.],	$
		det_index=1+BYTARR(9),sim_det_index=1+BYTARR(9),	$
		time_range=[0.,timeintv],sim_time_range=[0.,timeintv],	$
		sim_image_dim=imgdim, image_dim=imgdim
	
	check_hsi_img,simo,be=be,/GAUSS
END

;check_hsi_img,simo,be=be,/NORECOMPUTE

sourcesigmas=[0.001,0.1,0.5,1.,2.,3.,4.,5.,7.,10.,15.,20.,30.,50.,75.,100.]
photons_per_detector=[5000000.,50000.,10000.,1000.]

;=========================;==========================================================;===========================================================================================
;=========================;==========================================================;===========================================================================================

FOR i=0,N_ELEMENTS(sourcesigmas)-1 DO BEGIN
	FOR j=0,N_ELEMENTS(photons_per_detector)-1 DO BEGIN
		gg.xysigma = sourcesigmas[i]*[1.,1.]
		simo ->set, sim_model=gg,sim_photons_per_coll=photons_per_detector[j]
		check_hsi_img,simo,be=be,/GAUSS,fileroot='HESSI/simulations/sim_'+strn(sourcesigmas[i])+'_'+strn(photons_per_detector[j]+'_')
	ENDFOR
ENDFOR
END

