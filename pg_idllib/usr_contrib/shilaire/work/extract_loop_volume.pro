;
;
;
;
;

PRO extract_loop_volume, img

	n_sources_max=2

	imgdim=N_ELEMENTS(img[*,0])	
	src=REPLICATE({gra:-1d,grb:-1d,tet:0d,max:-1d,xmax:0d,ymax:0d},n_sources_max)
	extract_sources,img,src, NBMAX=n_sources_max,fmax=0.5
	ss=WHERE(src.gra GE 0)
	IF ss[0] NE -1 THEN src=src[ss]	
	src.gra=1/sqrt(src.gra)
	src.grb=1/sqrt(src.grb)

	im=img/MAX(img)
	plot_image,im,/VEL
	;CONTOUR,im,/OVER,LEVELS=[0.5,1.1]
	FOR k=0,1 DO mytvellipse,src[k].gra,src[k].grb,src[k].xmax,src[k].ymax,src[k].tet*180./!PI,/data
	
	d1=sqrt(src[0].gra^2 + src[0].grb^2)
	PRINT,'Source FWHM: '+strn(d1)
	d2=sqrt(src[1].gra^2 + src[1].grb^2)
	PRINT,'Source FWHM: '+strn(d2)
	d12=sqrt(  (src[0].xmax-src[1].xmax)^2 + (src[0].ymax-src[1].ymax)^2)
	PRINT,'Distance between sources: '+strn(d12)
	;V=!dPI^2 *d12*d1*d2/8. * (725e5)^3 ;using geometric mean
	V=!dPI^2 *d12 *((d1/2.)^2 + (d2/2.)^2 + d1*d2/4.)/3 * (725e5)^3  ;real volume
	PRINT,'Loop volume: (assuming 1 pixel=1"): '+strn(V)+' cm^3'
END
