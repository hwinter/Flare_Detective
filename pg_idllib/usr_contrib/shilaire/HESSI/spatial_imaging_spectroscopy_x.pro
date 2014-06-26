; imo should already be an ROI of a flare
;
;
;
; using the CENTER keyword (in pixels) imposes this point as the center of the crosshair i.e. the maximum of
;each image is not automatically taken.
;

;EXAMPLES:
;	spatial_imaging_spectroscopy_x,imo,spectrum=spectrum,imgs=imgs,LOUD=2	;,CENTER=[66,64] *OR* CENTER = an array of nimg such centers...
;	spatial_imaging_spectroscopy_x,imo,spectrum=spectrum,imgs=imgs,LOUD=1,/NORECOMP,center=cen


PRO spatial_imaging_spectroscopy_x,imo,		$
	LOUD=LOUD,ebands=ebands,npix=npix,NORECOMPUTE=NORECOMPUTE,CENTER=CENTER,	$
	spectrum=spectrum,imgs=imgs,avgspectrum=avgspectrum,ebins=ebins
	
	IF NOT KEYWORD_SET(ebands) THEN BEGIN
		ebands=10.+FINDGEN(10)
		ebands=[ebands,20.+5*FINDGEN(17)]
	ENDIF
	IF NOT KEYWORD_SET(npix) THEN npix=10
	IF NOT KEYWORD_SET(NORECOMPUTE) THEN NORECOMPUTE=0
	IF NOT KEYWORD_SET(LOUD) THEN LOUD=0
		
	nimgs=N_ELEMENTS(ebands)-1
	
IF NORECOMPUTE EQ 0 THEN BEGIN
	info=imo->get()
	spectrum=FINDGEN(nimgs,4,npix)
	imgs=FLTARR(info.image_dim[0],info.image_dim[1],nimgs)

	FOR i=0,nimgs-1 DO BEGIN
		imo->set,energy_band=[ebands[i],ebands[i+1]]
		imgs[*,*,i]=imo->getdata()
	ENDFOR	
ENDIF
		
	IF LOUD GE 2 THEN BEGIN
		hedc_win,900
		!P.MULTI=[0,5,6]
		FOR i=0,nimgs-1 DO BEGIN
			IF NOT KEYWORD_SET(CENTER) THEN xymax=max2d(imgs[*,*,i]) ELSE BEGIN
				IF N_ELEMENTS(CENTER[0,*]) EQ 1 THEN xymax=CENTER ELSE xymax=CENTER[*,i]
			ENDELSE
			
			plot_image,/VEL,imgs[*,*,i]
			OPLOT,psym=-7,[xymax[0]],[xymax[1]],color=0
			OPLOT,psym=-7,xymax[0]+[-npix,npix],[xymax[1],xymax[1]],color=0
			OPLOT,psym=-7,[xymax[0],xymax[0]],xymax[1]+[-npix,npix],color=0
		ENDFOR
		!P.MULTI=0
	ENDIF

	FOR i=0,nimgs-1 DO BEGIN
		IF NOT KEYWORD_SET(CENTER) THEN xymax=max2d(imgs[*,*,i]) ELSE BEGIN
			IF N_ELEMENTS(CENTER[0,*]) EQ 1 THEN xymax=CENTER ELSE xymax=CENTER[*,i]
		ENDELSE
		PRINT,'.......center: '+strn(xymax)
		FOR j=0,npix-1 DO BEGIN
			spectrum[i,0,j]=imgs[xymax[0]+j,xymax[1],i]
			spectrum[i,1,j]=imgs[xymax[0]-j,xymax[1],i]
			spectrum[i,2,j]=imgs[xymax[0],xymax[1]+j,i]
			spectrum[i,3,j]=imgs[xymax[0],xymax[1]-j,i]
			;normalize for energy bin size:
			spectrum[i,*,j]=spectrum[i,*,j]/(ebands[i+1]-ebands[i])
		ENDFOR
	ENDFOR	

avgspectrum=avg(spectrum,1)
fluxrng=MAX(avgspectrum)*[1/100000.,1.]
ebins=(ebands[0:nimgs-1]+ebands[1:nimgs])/2.

	IF LOUD GE 3 THEN BEGIN
		myct3,ct=1
		
		WINDOW,xs=768,ys=512,/FREE
		PLOT,ebins,spectrum[*,0,0],/XLOG,/YLOG,xtit='keV',ytit='photons in pixel',linestyle=0,color=254,tit='+X',yr=fluxrng
		FOR j=1,npix-1 DO OPLOT,ebins,spectrum[*,0,j],linestyle=1,color=254;230-20*j
		
		WINDOW,xs=768,ys=512,/FREE
		PLOT,ebins,spectrum[*,1,0],/XLOG,/YLOG,xtit='keV',ytit='photons in pixel',linestyle=0,color=254,tit='-X',yr=fluxrng
		FOR j=1,npix-1 DO OPLOT,ebins,spectrum[*,1,j],linestyle=1,color=254;230-20*j
		
		WINDOW,xs=768,ys=512,/FREE
		PLOT,ebins,spectrum[*,2,0],/XLOG,/YLOG,xtit='keV',ytit='photons in pixel',linestyle=0,color=254,tit='+Y',yr=fluxrng
		FOR j=1,npix-1 DO OPLOT,ebins,spectrum[*,2,j],linestyle=1,color=254;230-20*j
		
		WINDOW,xs=768,ys=512,/FREE
		PLOT,ebins,spectrum[*,3,0],/XLOG,/YLOG,xtit='keV',ytit='photons in pixel',linestyle=0,color=254,tit='-Y',yr=fluxrng
		FOR j=1,npix-1 DO OPLOT,ebins,spectrum[*,3,j],linestyle=1,color=254;230-20*j
	ENDIF
	
	IF LOUD GE 1 THEN BEGIN	
		WINDOW,xs=768,ys=512,/FREE
		myct3,ct=1
		PLOT,ebins,avgspectrum[*,0],/XLOG,/YLOG,xtit='Energy [keV]',ytit='Intensity profile [photons s!U-1!N cm!U-2!N asec!U-2!N kev!U-1!N]',linestyle=1,color=252,tit='Crosshair-averaged spectra for each pixel',yr=fluxrng;,psym=-7
		FOR j=0,npix-1 DO OPLOT,ebins,avgspectrum[*,j],linestyle=1,color=230-20*j
	ENDIF

;LINFIT for spectra
used_e=ebins[9:13]
used_sp=avgspectrum[9:13,*]

coeff=FLTARR(npix,2)
FOR i=0,npix-1 DO BEGIN
	coeff[i,*]=LINFIT(alog(used_e),alog(used_sp[*,i]),SIGMA=sigma,CHISQ=chisq)
	txt='Pixel: '+strn(i)+'   Spectral index: '+strn(-coeff[i,1])+'  Sigma: '+strn(sigma[1])+' CHISQ: '+strn(chisq)
	PRINT,txt
ENDFOR


; Flux vs. pixel number (i.e. distance from flare center)
	IF LOUD GE 1 THEN BEGIN	
		WINDOW,xs=768,ys=512,/FREE
		myct3,ct=1
		PLOT,FINDGEN(10)^2,avgspectrum[0,*],/YLOG,xtit='Square of distance from flare center [pixel!U2!N]',ytit='Flux in pixel [ph s!U-1!N cm!U-2!N asec!U-2!N kev!U-1!N]',linestyle=1,color=251,$
			tit='Crosshair-averaged fluxes for each pixel, different energy bands',yr=fluxrng	;,psym=-7
		FOR j=0,nimgs-1 DO OPLOT,FINDGEN(10)^2,avgspectrum[j,*],linestyle=1,color=230-7*j		
	ENDIF

;LINFIT for fluxes as a function of radial offset
used_pix=FINDGEN(10)
used_fluxes=avgspectrum[*,*]

coeff=FLTARR(nimgs,2)
FOR i=0,nimgs-1 DO BEGIN
	coeff[i,*]=LINFIT(used_pix^2,alog(used_fluxes[i,*]),SIGMA=sigma,CHISQ=chisq)
	txt='Eband: '+strn(ebins[i])+'   Slope: '+strn(coeff[i,1])+'  Sigma: '+strn(sigma[1])+' CHISQ: '+strn(chisq)
	PRINT,txt
ENDFOR
END
