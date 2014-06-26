
simo = hsi_image() 

pixsiz=1.
imgdim=256

timebins=FLOAT([1,1,2,4,8,8,16,32,64])/1000.
charsize=1.2
res=[2.3,3.9,6.9,11.9,20.7,35.9,62.1,107.,186.]
harmonic=0
gg = {gaussian_source_str} 
gg.xypos = [0.,0.] 
gg.tilt_angle_deg = 0. 
gg.amplitude = 1.0 
;==========================================================
gg.xysigma = 0.001*[1.,1.] 
;==========================================================

sourcesigma=[0.001,1.,3.,4.,5.,7.,10.,27.,81]
nsrc=N_ELEMENTS(sourcesigma)

hedc_win,900
!P.MULTI=[0,3,3]
Fmax=DBLARR(9,3,nsrc)
Fmin=DBLARR(9,3,nsrc)

FOR i=0,nsrc-1 DO BEGIN
	gg.xysigma = sourcesigma[i]*[1.,1.] 
	simo ->set, sim_model=gg,sim_photons_per_coll=5000000,  $
		sim_pixel_size=pixsiz, pixel_size=pixsiz, 	$
		energy_band=[12.,25.] ,			$
		sim_image_dim=imgdim, image_dim=imgdim, $
		det_index_mask=BYTARR(9)+1B
	tmp=simo->getdata()	
	be= simo -> getdata(class_name='hsi_binned_eventlist')
	
	FOR coll=0,8 DO BEGIN
		counts=(*be[coll,harmonic]).count
		Fmax[coll,harmonic,i]=MAX(counts)
		Fmin[coll,harmonic,i]=MIN(counts)
		;IF (Fmax[coll,harmonic,i]-Fmin[coll,harmonic,i]) GT 6*MEAN(counts)^0.5 THEN BEGIN
			Fmax[coll,harmonic,i]=Fmax[coll,harmonic,i]/timebins[coll]
			Fmin[coll,harmonic,i]=Fmin[coll,harmonic,i]/timebins[coll]
		;ENDIF ELSE BEGIN
		;	Fmax[coll,harmonic,i]=1.
		;	Fmin[coll,harmonic,i]=1.
		;ENDELSE	
	ENDFOR
	PLOT,/XLOG,res,(Fmax[*,harmonic,i]-Fmin[*,harmonic,i])/Fmax[*,harmonic,i],charsize=1.5*charsize,ymar=ymar,xtit='collimator resolution ["]',ytit='(Cmax-Cmin)/Cmax',psym=-7,tit='Source sigma: '+strn(sourcesigma[i])+'"',$
		yrange=[0.0,1.0],xrange=[1,1000]
ENDFOR
OBJ_DESTROY,simo
END
;========================================================================================================================================================
;========================================================================================================================================================
;========================================================================================================================================================
;========================================================================================================================================================
