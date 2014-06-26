; EXAMPLE:
;	rhessi_migen, '2002/02/26 '+['10:26','10:27'], [12,25],	
;	rhessi_migen, '2002/02/26 '+[['10:26','10:27'],['10:27','10:28']], [[6,12],[12,25],[25,50]],	
;

PRO rhessi_migen, time_intvs, ebands, xyoffset, fitsfile, imgalg=imgalg, pixsiz=pixsiz, imgdim=imgdim, detindex=detindex

	IF NOT KEYWORD_SET(imgalg) THEN imgalg='clean'
	IF NOT KEYWORD_SET(imgdim) THEN imgdim=128
	IF NOT KEYWORD_SET(pixsiz) THEN pixsiz=1
	IF NOT KEYWORD_SET(detindex) THEN detindex=[0,0,1,1,1,1,1,0,0]
	
	mmo=hsi_multi_image()
	mmo->set,im_time_interval=anytim(time_intvs)
	mmo->set,im_energy_bin=ebands
	ss=WHERE(ebands GT 100) & IF ss[0] EQ -1 THEN mmo->set,FRONT=1,REAR=0 ELSE mmo->set,FRONT=1,REAR=1 		;If ANY of the ebands is above 100, have to use rear detectors for ALL images...
	mmo->set,image_alg=imgalg,pixel_size=pixsize,image_dim=imgdim,xyoffset=xyoffset,det_index_mask=detindex
	mmo->set_no_screen_output
	mmo->set,progress_bar=0
	mmo->set,multi_fits_filename=fitsfile
	imagetesseract=mmo->getdata()	
	OBJ_DESTROY,mmo
END
