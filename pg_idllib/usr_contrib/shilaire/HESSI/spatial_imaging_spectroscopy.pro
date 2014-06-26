;EXAMPLES:
;	spatial_imaging_spectroscopy,imo,925,-225,spectrum=spectrum,imgs=imgs,maxspectrum=maxspectrum,/LOUD
;


PRO spatial_imaging_spectroscopy,imo,xarc,yarc, $
	LOUD=LOUD,ebands=ebands,		$
	spectrum=spectrum,imgs=imgs,maxspectrum=maxspectrum
	
	IF NOT KEYWORD_SET(ebands) THEN ebands=5.+5.*FINDGEN(20)
	
	nimgs=N_ELEMENTS(ebands)-1
	npix=N_ELEMENTS(xarc)	

	imo->set,image_alg='back'
	info=imo->get()
	spectrum=FINDGEN(nimgs,npix)
	maxspectrum=FINDGEN(nimgs)
	imgs=FLTARR(info.image_dim[0],info.image_dim[1],nimgs)

	;from xycoord to xypixelcoord
	xp=(xarc-info.xyoffset[0])/info.pixel_size[0] + info.image_dim[0]/2
	yp=(yarc-info.xyoffset[1])/info.pixel_size[1] + info.image_dim[1]/2
	
	FOR i=0,nimgs-1 DO BEGIN
		imo->set,energy_band=[ebands[i],ebands[i+1]]
		imgs[*,*,i]=imo->getdata()
		IF KEYWORD_SET(LOUD) THEN BEGIN
			hessi_ct
			imo->plot,/CBAR,charsize=1.2,grid=10
			OPLOT,psym=-7,[xarc],[yarc],color=0
		ENDIF
		FOR j=0,npix-1 DO BEGIN
			spectrum[i,j]=imgs[xp[j],yp[j],i]
		ENDFOR
		maxspectrum[i]=MAX(imgs[*,*,i])
	ENDFOR	
	IF KEYWORD_SET(LOUD) THEN BEGIN
		WINDOW,xs=768,ys=512,/FREE
		ebins=ebands[0]+(ebands[1]-ebands[0])*(FINDGEN(nimgs)+0.5)
		myct3,ct=1
		totspectrum=TOTAL(spectrum,2)
		PLOT,ebins,totspectrum,/XLOG,/YLOG,xtit='keV',ytit='photons in pixel',linestyle=0
		OPLOT,ebins,totspectrum,linestyle=1,color=252
		OPLOT,ebins,maxspectrum,linestyle=1,color=255
		FOR j=0,npix-1 DO BEGIN
			OPLOT,ebins,spectrum[*,j],linestyle=1,color=220-20*j
		ENDFOR
	ENDIF
END

