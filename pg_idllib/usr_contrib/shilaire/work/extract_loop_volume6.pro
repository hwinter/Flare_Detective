; EX:
;	extract_loop_volume6,'2002/02/20 '+['11:06:08','11:07:08'],[907,261],/SPECTRUM
;
;
;

PRO extract_loop_volume6, time_intv, xyoffset, SPECTRUM=SPECTRUM

	IF KEYWORD_SET(SPECTRUM) THEN BEGIN
		psh_win,768,512
		spo=hsi_spectrum()
		spo->set,time_range=time_intv
		spo->set,seg_index_mask=[1,0,1,1,1,1,0,1,1,0,0,0,0,0,0,0,0,0],sp_energy_bin=1,sp_semi_cal=0,DECIMATION_CORRECT=1 ;,PILEUP_CORRECT=1
		spo->plot
		PRINT,"Hit any key to go on..."
		tmp=GET_KBRD(1)
	ENDIF

	ebands=[[4,6],[6,8],[12,25],[25,50]]
	n_ebands=N_ELEMENTS(ebands[0,*])
	
	pixsiz=1.
	imgdim=128
	n_sources_max=2
	psh_win,768,n_ebands*256
	;!P.MULTI=[0,3,n_ebands,0,1]
	!P.MULTI=[0,3,n_ebands]
	hessi_ct,/QUICK
	rainbow_linecolors
	
	imo=hsi_image()	
	imo->set,time_range=time_intv
	imo->set,xyoffset=xyoffset,image_dim=imgdim,pixel_size=pixsiz
	imo->set,image_alg='clean'
	imo->set_no_screen_output
;	imo->plot,/LIMB,grid=90

	pshFWHM_arr='bla'
	d1_arr='bla'
	dd1_arr='bla'
	d2_arr='bla'
	dd2_arr='bla'
	d12_arr='bla'
	V_arr='bla'


	FOR j=0,n_ebands-1 DO BEGIN
		imo->set,energy_band=ebands[*,j]			
		FOR i=0,2 DO BEGIN
			CASE i OF 
				1:det=[0,1,1,1,1,1,1,0,0]
				2:det=[1,1,1,1,1,1,1,0,0]
				ELSE:det=[0,0,1,1,1,1,1,0,0]
			ENDCASE
			imo->set,det_index=det		
			img=imo->getdata()
	
		IF N_ELEMENTS(img) NE 1 THEN BEGIN
			;now, get the CLEAN beam:
			annsec_psf=imo->getdata(class='hsi_psf',xy_pixel=imgdim*[0.5,0.5],det_index=det)
			IF N_ELEMENTS(annsec_psf) GT 1 THEN BEGIN
				xy_psf=hsi_annsec2xy(annsec_psf,imo)
				res=GAUSS2dFIT(xy_psf,a)
				psfFWHM=pixsiz*2.355*MEAN(a[2:3])	;in "
			ENDIF ELSE psfFWHM=0.
			PRINT,'CLEAN psf FWHM ["]: '+strn(psfFWHM)		
	
			src=REPLICATE({gra:-1d,grb:-1d,tet:0d,max:-1d,xmax:0d,ymax:0d},n_sources_max)
			extract_sources,img,src, NBMAX=n_sources_max,fmax=0.5
			ss=WHERE(src.gra GE 0) & IF ss[0] NE -1 THEN src=src[ss]	
			IF N_ELEMENTS(ss) LT 2 THEN BEGIN
				PRINT,'Problem determining sources with this one...'
				plot_image_v2,img
				;imo->plot,/LIMB,grid=90,label_size=1.0
				GOTO, NEXTPLEASE
			ENDIF
			
			src.gra=2/sqrt(src.gra)	& src.grb=2/sqrt(src.grb)	; those are now FWHM. I've tested!!!! PSH 2003/12/05
		
			im=img/MAX(ABS(img))
			;plot_image,im,/VEL
			plot_image_v2,im
			FOR k=0,1 DO mytvellipse,src[k].gra/2.355,src[k].grb/2.355,src[k].xmax,src[k].ymax,src[k].tet*180./!PI,/data,color=4
			;FOR k=0,1 DO mytvellipse,sqrt(src[k].gra^2-psfFWHM^2)/2.355,sqrt(src[k].grb^2-psfFWHM^2)/2.355,src[k].xmax,src[k].ymax,src[k].tet*180./!PI,/data,color=4
		
			d1=pixsiz*sqrt(src[0].gra^2 + src[0].grb^2)	;in "
			dd1=sqrt(d1^2-psfFWHM^2)
			d2=pixsiz*sqrt(src[1].gra^2 + src[1].grb^2)
			dd2=sqrt(d2^2-psfFWHM^2)
			d12=pixsiz*sqrt(  (src[0].xmax-src[1].xmax)^2 + (src[0].ymax-src[1].ymax)^2)
			;V=!dPI^2 *d12*d1*d2/8. * (725e5)^3 ;using geometric mean
			V=!dPI^2 *d12 *((dd1/2.)^2 + (dd2/2.)^2 + dd1*dd2/4.)/3 * (725e5)^3  ;real volume
				
			lcolor=4
			lchar=1.0
			label_plot,0.03,-1, anytim(time_intv[0],/date,/ECS)+' '+anytim(time_intv[0],/time,/ECS,/TRUNC)+'-'+anytim(time_intv[1],/time,/ECS,/TRUNC),charsize=lchar,color=lcolor
			label_plot,0.03,-2, 'Eband: '+strn(ebands[0,j])+'-'+strn(ebands[1,j])+'   Det: '+STRJOIN(STRTRIM(det,2)),charsize=lchar,color=lcolor
			label_plot,0.03,-3, 'XYoffset: '+strn(xyoffset[0])+','+strn(xyoffset[1]),charsize=lchar,color=lcolor
			label_plot, 0.03, 5,'psf FWHM: '+strn(psfFWHM,format='(f10.2)')+'"',charsize=lchar,color=lcolor
			label_plot, 0.03, 4,'S1: '+strn(d1,format='(f10.2)')+'"/'+strn(dd1,format='(f10.2)')+'"',charsize=lchar,color=lcolor
			label_plot, 0.03, 3,'S2: '+strn(d2,format='(f10.2)')+'"/'+strn(dd2,format='(f10.2)')+'"',charsize=lchar,color=lcolor
			label_plot, 0.03, 2,'d12: '+strn(d12,format='(f10.2)')+'"',charsize=lchar,color=lcolor
			label_plot, 0.03, 1,'V: '+strn(V)+' cm!U3!N',charsize=lchar,color=lcolor
	
			IF datatype(V_arr) EQ 'STR' THEN BEGIN
				pshFWHM_arr=psfFWHM
				d1_arr=d1
				dd1_arr=dd1
				d2_arr=d2
				dd2_arr=dd2
				d12_arr=d12
				V_arr=V
			ENDIF ELSE BEGIN
				pshFWHM_arr=[pshFWHM_arr,psfFWHM]
				d1_arr=[d1_arr,d1]
				dd1_arr=[dd1_arr,dd1]
				d2_arr=[d2_arr,d2]
				dd2_arr=[dd2_arr,dd2]
				d12_arr=[d12_arr,d12]
				V_arr=[V_arr,V]
			ENDELSE
		ENDIF ELSE PRINT,'No image...'	
			NEXTPLEASE:
		ENDFOR
	ENDFOR
	OBJ_DESTROY,imo
END



