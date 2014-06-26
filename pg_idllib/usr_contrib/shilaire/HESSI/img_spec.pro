; imo should already be an ROI of a flare
;
;	\NONORMALIZE: is set, will not normalize imgs (and hence pixspg) for accum. time interval
;
; using the CENTER keyword (in pixels) imposes this point as the center of the crosshair i.e. the maximum of
;each image is not automatically taken.
;

;EXAMPLES:
;	imo=hsi_image()
;	imo->set,image_dim=128,pixel_size=1,det_index_mask=[0,0,1,1,1,1,1,1,0],xyoffset=[925,-225]
;	time_intvs='2002/02/26 10:'+[['26:00','26:31'],['26:31','27:02'],['27:02','27:33'],['27:33','28:04'],['28:04','28:35']]
;	time_intvs='2002/02/26 10:'+[['26:00','26:20'],['26:20','26:40'],['26:40','27:00'],['27:00','27:20'],['27:20','27:40'],['27:40','28:00'],['28:00','28:20'],['28:20','28:40'],['28:40','29:00']]
;	img_spec,imo,time_intvs,pixspg=pixspg,imgs=imgs,xhairspg=xhairspg,LOUD=3	;,CENTER=[66,64]


PRO img_spec,imo,time_intvs,		$
	LOUD=LOUD,ebands=ebands,npix=npix,NORECOMPUTE=NORECOMPUTE,CENTER=CENTER,	$
	imgs=imgs,ebins=ebins,pixspg=pixspg
	
	IF NOT KEYWORD_SET(ebands) THEN ebands=10.+5.*FINDGEN(19)
	IF NOT KEYWORD_SET(npix) THEN npix=10
	IF NOT KEYWORD_SET(NORECOMPUTE) THEN NORECOMPUTE=0
	IF NOT KEYWORD_SET(LOUD) THEN LOUD=0

	nintv=N_ELEMENTS(time_intvs[0,*])		
	neband=N_ELEMENTS(ebands)-1
	ebins=ebands[0]+(ebands[1]-ebands[0])*(FINDGEN(neband)+0.5)
		
IF NORECOMPUTE EQ 0 THEN BEGIN
	info=imo->get()
	xhairspg=FINDGEN(4,npix,neband,nintv)
	imgs=FLTARR(info.image_dim[0],info.image_dim[1],neband,nintv)
	
	FOR i=0,neband-1 DO BEGIN
		FOR j=0, nintv-1 DO BEGIN
			imo->set,energy_band=[ebands[i],ebands[i+1]],time_range=time_intvs[*,j]				
			tmp=imo->getdata()
			imgs[*,*,i,j]=tmp
			IF LOUD GE 3 THEN imo->plot,charsize=1.5,grid=10,/LIMB
		ENDFOR
	ENDFOR	

	;THE MAIN STUFF:
	FOR i=0,neband-1 DO BEGIN
		FOR j=0,nintv-1 DO BEGIN
			IF NOT KEYWORD_SET(CENTER) THEN xymax=max2d(imgs[*,*,i,j]) ELSE xymax=CENTER
			FOR k=0,npix-1 DO BEGIN
				xhairspg[0,k,i,j]=imgs[xymax[0]+k,xymax[1],i,j]
				xhairspg[1,k,i,j]=imgs[xymax[0]-k,xymax[1],i,j]
				xhairspg[2,k,i,j]=imgs[xymax[0],xymax[1]+k,i,j]
				xhairspg[3,k,i,j]=imgs[xymax[0],xymax[1]-k,i,j]
			ENDFOR			
		ENDFOR
	ENDFOR

	;pixspg is the average over the pixel axes of the xhairspg.
	pixspg=avg(xhairspg,0)
ENDIF


; FOR each ebin, make a spatial plot dist^2 vs. Flux, averaged over time, at start, at end, at peak time
; FOR each pixel distance from flare center, make a spectrum, averaged over time, at start, at end, at peak time

; see the end os spatial_imaging_spectroscopy_x.pro for details on this...

END
