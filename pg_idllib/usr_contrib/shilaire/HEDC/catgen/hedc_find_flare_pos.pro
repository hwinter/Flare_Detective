
;This routine, given a time interval, returns the (hopefully correct) HESSI flare position, in arcseconds from Sun center
; the accuracy is only +/-pixel_size".
;
;	EXAMPLE: 
;		PRINT,hedc_find_flare_pos(time_intv,/LOUD)
;
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
;
;


FUNCTION hedc_find_flare_pos,time_intv,LOUD=LOUD,pixel_size=pixel_size,NOBREAK=NOBREAK

	es=0
	IF KEYWORD_SET(NOBREAK) THEN CATCH,es
	IF es NE 0 THEN BEGIN
		CATCH,/CANCEL
		es=0
		PRINT,'...............................CAUGHT ERROR IN hedc_find_flare_pos.pro !......................'
		HELP, CALLS=caller_stack
		PRINT, 'Error index: ', es
		PRINT, 'Error message:', !ERR_STRING
		PRINT,'Error caller stack:',caller_stack
		HELP, /Last_Message, Output=theErrorMessage
		FOR j=0,N_Elements(theErrorMessage)-1 DO PRINT, theErrorMessage[j]
			
		RETURN,'Problem with hedc_find_flare.'
	ENDIF

	N_methods=6;	
	Method_weight=[2.,1.,1.,1.,1.,3.]
	IF NOT KEYWORD_SET(pixel_size) THEN pixel_size=32
	image_dim=2048/pixel_size
			
	maxx=FLTARR(N_methods)
	maxy=FLTARR(N_methods)
	maxxy_pix=INTARR(2,N_methods)
	
	imotep=hsi_image()
	imotep->set,time_range=time_intv
	imotep->set,xyoffset=[0,0],pixel_size=pixel_size,image_dim=image_dim

	IF KEYWORD_SET(LOUD) THEN !P.MULTI=[0,3,2]
	
	;method 1: back proj. of SC#7
	imotep->set,image_alg='back'
	imotep->set,det_index_mask=[0,0,0,0,0,0,1,0,0]
	maxxy_pix[*,0]=max2d(imotep->getdata())
	IF KEYWORD_SET(LOUD) THEN plot_image,imotep->getdata()
	
	;method 2: back proj. of SC#8
	imotep->set,image_alg='back'
	imotep->set,det_index_mask=[0,0,0,0,0,0,0,1,0]
	maxxy_pix[*,1]=max2d(imotep->getdata())
	IF KEYWORD_SET(LOUD) THEN plot_image,imotep->getdata()

	;method 3: back proj. of SC#9
	imotep->set,image_alg='back'
	imotep->set,det_index_mask=[0,0,0,0,0,0,0,0,1]
	maxxy_pix[*,2]=max2d(imotep->getdata())
	IF KEYWORD_SET(LOUD) THEN plot_image,imotep->getdata()

	;method 4: Ffit of SC#7-8
	imotep->set,image_alg='forwardfit'
	imotep->set_no_screen_output
	imotep->set,det_index_mask=[0,0,0,0,0,0,1,1,0]
	maxxy_pix[*,3]=max2d(imotep->getdata())
	IF KEYWORD_SET(LOUD) THEN plot_image,imotep->getdata()

	;method 5: Ffit of SC#8-9
	imotep->set,image_alg='forwardfit'
	imotep->set_no_screen_output
	imotep->set,det_index_mask=[0,0,0,0,0,0,0,1,1]
	maxxy_pix[*,4]=max2d(imotep->getdata())
	IF KEYWORD_SET(LOUD) THEN plot_image,imotep->getdata()

	;method 6: Ffit of SC#7-9
	imotep->set,image_alg='forwardfit'
	imotep->set_no_screen_output
	imotep->set,det_index_mask=[0,0,0,0,0,0,1,1,1]
	maxxy_pix[*,5]=max2d(imotep->getdata())
	IF KEYWORD_SET(LOUD) THEN plot_image,imotep->getdata()
	
	OBJ_DESTROY,imotep
	IF KEYWORD_SET(LOUD) THEN !P.MULTI=0

	;Decision making process
	;1) majority wins	
	SolarImage=FLTARR(image_dim,image_dim)
	FOR i=0, N_methods-1 DO SolarImage[maxxy_pix[0,i],maxxy_pix[1,i]]=SolarImage[maxxy_pix[0,i],maxxy_pix[1,i]]+Method_weight[i]
	;SolarImage=SMOOTH(SolarImage,3,/EDGE)
	maxxy=max2d(SolarImage)
	ss=WHERE(SolarImage EQ maxxy)
	IF N_ELEMENTS(ss) LT 2 THEN RETURN,(maxxy-image_dim/2 + 0.5)*pixel_size
	;2) in case of a draw, ffit 7-9 decides
	RETURN,(maxxy_pix[*,5]-image_dim/2 + 0.5)*pixel_size
END

