; EX:
;	extract_loop_volume3,'2002/02/20 '+['11:06:08','11:07:08'],[907,261]
;
;
;

PRO extract_loop_volume3, time_intv, xyoffset, eband=eband, det=det

	IF NOT KEYWORD_SET(eband) THEN eband=[25,50]
	IF NOT KEYWORD_SET(det) THEN det=[0,0,1,1,1,1,1,0,0]
	
	pixsiz=1.
	imgdim=128
	n_sources_max=2
	
	imo=hsi_image()	
	imo->set,time_range=time_intv
	imo->set,energy_band=eband
	imo->set,xyoffset=xyoffset,image_dim=imgdim,pixel_size=pixsiz,det_index=det
	imo->set,image_alg='clean'
	imo->set_no_screen_output
	hessi_ct,/QUICK
;	imo->plot,/LIMB,grid=90
	img=imo->getdata()

	;now, get the CLEAN beam:
	annsec_psf=imo->getdata(class='hsi_psf',xy_pixel=imgdim*[0.5,0.5],det_index=det)
	xy_psf=hsi_annsec2xy(annsec_psf,imo)
	res=GAUSS2dFIT(xy_psf,a)
	psfFWHM=pixsiz*2.355*MEAN(a[2:3])	;in "
	PRINT,'CLEAN psf FWHM ["]: '+strn(psfFWHM)
	
	OBJ_DESTROY,imo

	src=REPLICATE({gra:-1d,grb:-1d,tet:0d,max:-1d,xmax:0d,ymax:0d},n_sources_max)
	extract_sources,img,src, NBMAX=n_sources_max,fmax=0.5
	ss=WHERE(src.gra GE 0) & IF ss[0] NE -1 THEN src=src[ss]	
	src.gra=2/sqrt(src.gra)	& src.grb=2/sqrt(src.grb)	; those are now FWHM. I've tested!!!! PSH 2003/12/05

	im=img/MAX(img)
	plot_image,im,/VEL
	FOR k=0,1 DO mytvellipse,src[k].gra/2.355,src[k].grb/2.355,src[k].xmax,src[k].ymax,src[k].tet*180./!PI,/data
	;FOR k=0,1 DO mytvellipse,sqrt(src[k].gra^2-psfFWHM^2)/2.355,sqrt(src[k].grb^2-psfFWHM^2)/2.355,src[k].xmax,src[k].ymax,src[k].tet*180./!PI,/data

	d1=pixsiz*sqrt(src[0].gra^2 + src[0].grb^2)	;in "
	dd1=sqrt(d1^2-psfFWHM^2)
	PRINT,'Source FWHM ["]: '+strn(d1)+'   Deconvolved: '+strn(dd1)
	d2=pixsiz*sqrt(src[1].gra^2 + src[1].grb^2)
	dd2=sqrt(d2^2-psfFWHM^2)
	PRINT,'Source FWHM ["]: '+strn(d2)+'   Deconvolved: '+strn(dd2)
	d12=pixsiz*sqrt(  (src[0].xmax-src[1].xmax)^2 + (src[0].ymax-src[1].ymax)^2)
	PRINT,'Distance between sources ["]: '+strn(d12)
	;V=!dPI^2 *d12*d1*d2/8. * (725e5)^3 ;using geometric mean
	V=!dPI^2 *d12 *((dd1/2.)^2 + (dd2/2.)^2 + dd1*dd2/4.)/3 * (725e5)^3  ;real volume
	PRINT,'Loop volume: '+strn(V)+' cm^3'


END
