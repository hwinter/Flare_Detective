; EX:
;	extract_loop_volume2,'2002/02/20 '+['11:06:08','11:07:08'],[907,261]
;
;
;

PRO extract_loop_volume2, time_intv, xyoffset, eband=eband, det=det

	IF NOT KEYWORD_SET(eband) THEN eband=[25,50]
	IF NOT KEYWORD_SET(det) THEN det=[1,1,1,1,1,1,1,0,0]
	
	imo=hsi_image()	
	imo->set,time_range=time_intv
	imo->set,energy_band=eband
	imo->set,xyoffset=xyoffset,image_dim=128,pixel_size=1,det_index=det
	imo->set,image_alg='forwardfit'
	imo->set,ff_n_gauss=2,ff_n_par=4
	imo->set_no_screen_output
	hessi_ct
	imo->plot,/LIMB,grid=90

	src=imo->get(/ff_coeff_ff)
	OBJ_DESTROY,imo
	
;source FWHM	["]
	fwhm1=2.355*src[1,0]
	fwhm2=2.355*src[1,1]
;sections	[cm^2]
	s1=!dPI*(725e5*fwhm1/2)^2
	s2=!dPI*(725e5*fwhm2/2)^2
;distance	[cm]
	d=725e5*sqrt( (src[2,0]-src[2,1])^2 + (src[3,0]-src[3,1])^2  )
;loop length	[cm]
	l=!dPI*d
;loop volume	
	V=sqrt(s1*s2)*l

;print output	
	PRINT,'Source FWHM: '+strn(fwhm1)+'   '+strn(fwhm2)
	PRINT,'Sections [cm^2]: '+strn(s1)+'   '+strn(s2)
	PRINT,'Length [cm]: '+strn(l)
	PRINT,'Loop volume: [cm^3]: '+strn(V)
END
