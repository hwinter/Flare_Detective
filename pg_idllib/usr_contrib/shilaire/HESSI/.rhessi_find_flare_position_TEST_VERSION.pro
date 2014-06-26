;		Some intervals of problematic flares:
;		time_intv='2002/07/23 '+['00:35:00','00:35:12']
;		time_intv='2002/07/29 '+['02:36:39.9','02:36:52.1']
;		time_intv='2002/03/03 '+['02:04:00','02:04:12']
;		time_intv='2002/03/05 '+['05:32:36','05:33:28']
;		time_intv='2002/03/06 '+['08:36:20','08:37:20']
;		time_intv='2002/03/29 '+['20:44:48','20:45:08']	;FFIT CRASH!
;		time_intv='2002/04/03 '+['05:32:28','05:33:20']
;		time_intv='2002/04/03 '+['21:49:48','21:50:00'] ;FFIT CRASH!
;		time_intv='2002/04/04 '+['09:03:36','09:03:56']
;		time_intv='2002/04/04 '+['10:45:52','10:46:04'] ;FFIT CRASH!
;		time_intv='2002/04/04 '+['15:30:04','15:30:16']
;		time_intv='2002/04/06 '+['06:16:06','06:16:20']
;		time_intv='2002/04/06 '+['14:06:36','14:07:04']
;		time_intv='2002/04/07 '+['07:24:00','07:25:00']
;		time_intv='2002/04/07 '+['12:44:36','12:45:36']
;		time_intv='2002/04/09 '+['06:06:12','06:06:24']	;only flare found so far where ffit with SC#7-9 fails (and ~everythin else also fails...)
;		time_intv='2002/04/09 '+['06:06:12','06:06:24']	
;		time_intv='2002/05/29 '+['03:32:48','03:33:00']	
;		time_intv='2002/05/29 '+['15:03:20','15:03:32']	
;		time_intv='2002/05/30 '+['05:02:20','05:02:32']	
;		time_intv='2002/05/30 '+['05:02:20','05:02:32']	
;=========================================================================================================================================================            
FUNCTION rhessi_find_flare_position, time, coll=coll, LOUD=LOUD, $
			warning=warning
			
	;1) use collimator 8
	;2) if failure in producing plot, try another time range
	;3) if less than 3000 counts, take triple time_intv....
	
	IF NOT KEYWORD_SET(coll) THEN coll=7	;coll#8 seems to be slightly more reliable than SC#7 or SC#9 for this.

	detres=[2.3,3.9,6.9,11.9,20.7,35.9,62.1,107.,186.]
	warning=0
	err=0
	CATCH,err
	IF err NE 0 THEN BEGIN
		CATCH,/CANCEL
		PRINT,'............CAUGHT ERROR!...'
		HELP, /Last_Message, Output=theErrorMessage
                FOR j=0,N_Elements(theErrorMessage)-1 DO PRINT, theErrorMessage[j]
		PRINT,'............Problem with rhessi_find_flare_position.pro: returning -1...'
		RETURN,-1
	ENDIF

	IF N_ELEMENTS(time) EQ 2 THEN time_intv=anytim(time) ELSE time_intv=anytim(time)+[-6.,6.]*rhessi_get_spin_period(time,/DEF)
	imo=hsi_image()
	imo->set,time_range=time_intv,energy_band=[12,25]
	imo->set,image_dim=128,pixel_size=16,xyoffset=[0,0]	; just about anything should be a point source...
	
	tmp=BYTARR(9) & tmp[coll]=1B & imo->set,det_index=tmp
	img=imo->getdata()
	IF img[0,0] EQ -1 THEN MESSAGE,'....... getdata on image failed!!!'
	info=imo->get()

	tmp=imo->get(/binned_n_event) & counts=tmp[coll,0]
	cbe=imo->GetData( CLASS_NAME = 'HSI_Calib_eventlist' )
	P_m=MEAN( (*cbe[coll,0]).gridtran*(1.+(*cbe[coll,0]).modamp*cos((*cbe[coll,0]).phase_map_ctr)))	
	;assuming the source is over-resolved, one should have a relative amplitude of 1, and hence:
	theoretical_peakvalue=1.0*counts/P_m
		
	ij=max2d(img)
	x=(ij[0]-info.image_dim[0]/2)*info.pixel_size[0]
	y=(ij[1]-info.image_dim[1]/2)*info.pixel_size[1]
	PRINT,'Expected peak value (single point source) = '+strn(theoretical_peakvalue)
	PRINT,'Peakvalue = '+strn(MAX(img))+' at position: '+strn(x)+' '+strn(y)+' .'

	xy_spin_axis=rhessi_get_spin_axis_position(time_intv,radius=radius,sigma_radius=sigma_radius)
	IF N_ELEMENTS(xy_spin_axis) NE 2 THEN BEGIN
		warning=warning+4	;bit 2
		GOTO,THEEND
	ENDIF
	
;-------1) if brightest pixel is more than radius+3*sigma_radius away from spin axis, must be the right place.
	; (another check could involve the expected flux for a single point source in this brightest pixel...)
		IF ( (x-xy_spin_axis[0])^2 + (y-xy_spin_axis[1])^2 )^0.5 GT detres[coll] THEN GOTO,THEEND
	
;-------2) if the brightest pixel was close to the spin axis, it is suspected to be an effect of the spin axis.
	;	hence, put every pixel near the spin axis to zero, and find a new "brightest pixel".
		img2=img	;img2 will have all pixels near the spin axis put to zero.
		FOR i=0,N_ELEMENTS(img[*,0])-1 DO BEGIN
			FOR j=0,N_ELEMENTS(img[0,*])-1 DO BEGIN
				IF ( info.pixel_size[0]*((i-ij[0])^2 + (j-ij[1])^2 )^0.5) LE detres[coll] THEN img2[i,j]=0.			
			ENDFOR
		ENDFOR
		ij2=max2d(img2)
		x=(ij2[0]-info.image_dim[0]/2)*info.pixel_size[0]
		y=(ij2[1]-info.image_dim[1]/2)*info.pixel_size[1]
		PRINT,'New peakvalue = '+strn(MAX(img2))+' at position: '+strn(x)+' '+strn(y)+' .'
		
;-------3) issue a warning whenever the new position is along the edge of the previously zeroed spin axis region...
		IF ((x-xy_spin_axis[0])^2 + (y-xy_spin_axis[0])^2)^0.5 LE (detres[coll]*1.1) THEN warning=warning+2	; bit 1

;---------
THEEND:
;------- issue warning if total number of counts was a bit low...
		;osro=hsi_obs_summ_rate()
		;osro->set,obs_time=time_intv
		;rates_struct=osro->getdata()
		;IF datatype(rates_struct.COUNTRATE) EQ 'BYT' THEN rates=hsi_obs_summ_decompress(rates_struct.COUNTRATE) ELSE rates=rates_struct.COUNTRATE
		;
		;deltat=osro->get(/time_intv)
		;OBJ_DESTROY,osro
		;IF N_ELEMENTS(rates_struct) GT 1 THEN totcounts=deltat*TOTAL(rates[2,*]) ELSE totcounts=-1
		;IF totcounts LT 3000 THEN warning=warning+1	; bit 0
		IF counts LT 3000 THEN warning=warning+1	; bit 0


	IF KEYWORD_SET(LOUD) THEN BEGIN
		!P.MULTI=[0,3,1]
		imo->plot,/limb,label_size=1.0,xtit='',ytit='',tit='',mar=0.01,xmar=[1,1],ymar=[1,1],xtickname=REPLICATE(' ',10),ytickname=REPLICATE(' ',10)
		;display spin axis position
		IF N_ELEMENTS(xy_spin_axis) EQ 2 THEN BEGIN
			PLOTS,/DATA,[xy_spin_axis[0],xy_spin_axis[0]],[-1000,1000],linestyle=1
			PLOTS,/DATA,[-1000,1000],[xy_spin_axis[1],xy_spin_axis[1]],linestyle=1
		ENDIF
		;display found flare location
		PLOTS,/DATA,[x,x],[-1000,1000],linestyle=0
		PLOTS,/DATA,[-1000,1000],[y,y],linestyle=0		
		;display number of counts...
		XYOUTS,/DATA,600,-950,strn(counts)
		IF warning GT 0 THEN BEGIN
			text='Warning: '+strn(warning)
			XYOUTS,/DATA,-950,-950,text
		ENDIF
		imo->set,det_index=[0,0,0,0,0,0,1,0,0]
		imo->plot,/limb,label_size=1.0,xtit='',ytit='',tit='',mar=0.01,xmar=[1,1],ymar=[1,1],xtickname=REPLICATE(' ',10),ytickname=REPLICATE(' ',10)
		imo->set,det_index=[0,0,0,0,0,0,0,0,1]
		imo->plot,/limb,label_size=1.0,xtit='',ytit='',tit='',mar=0.01,xmar=[1,1],ymar=[1,1],xtickname=REPLICATE(' ',10),ytickname=REPLICATE(' ',10)	
	ENDIF

	OBJ_DESTROY,imo
	RETURN,[x,y]
END
;=====================================================================================================================



