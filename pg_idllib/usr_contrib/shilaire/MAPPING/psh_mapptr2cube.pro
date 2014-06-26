; makes an imagecube that can be visualized with XSTEPPER.pro, or later transformed into a MPEG, etc...
;
; EXAMPLE:
;	outdir='TEMP/'
;	psh_smmdac_download,'TRACE','2002/08/22 '+['01:40','02:00'], files=files, outdir,wl='195'
;	mapptr=psh_fitsfiles2map(outdir+files)
;	cube=psh_mapptr2cube(mapptr,xr=[700,900],yr=[-400,-200],/LOG)
;	xstepper,cube
;

FUNCTION psh_mapptr2cube, mapptr, _extra=_extra

	imgdim=512
	n_imgs=N_ELEMENTS(mapptr)
	cube=BYTARR(imgdim,imgdim,n_imgs)

	psh_win,imgdim
	
	FOR i=0,n_imgs-1 DO BEGIN
		plot_map,*mapptr[i],_extra=_extra
		cube[*,*,i]=TVRD()
	ENDFOR

	RETURN,cube
END
