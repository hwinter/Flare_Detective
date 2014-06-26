;pixelsize is an array of pixel sizes for the different SCs.
;IF single-valued, it will be the same for all SCs.
; image_dim is always 128

;EXAMPLE: hedc_sc_panel_plot,imo,charsize=1.0,PSout='/global/helene/users/shilaire/20020226/sc_panel_short.ps'


PRO hedc_sc_panel_plot,imo,pixelsize=pixelsize,PSout=PSout, SHADE_SURF=SHADE_SURF
	
	charsize=1.5
	label_size=0.7

	;absolutes:
	detres=[2.3,3.9,6.9,11.9,20.7,35.9,62.1,107.,186.]
	harmonic=0

	IF NOT KEYWORD_SET(pixelsize) THEN BEGIN
		pixelsize=detres/10.
	ENDIF ELSE BEGIN
		IF N_ELEMENTS(pixelsize) EQ 1 THEN pixelsize=REPLICATE(pixelsize,9)
	ENDELSE
		
	info=imo->get()
	
	!P.MULTI=[0,3,3]
	
	IF KEYWORD_SET(PSout) THEN BEGIN
		SET_PLOT,'PS'
		old_device=!D.NAME
		DEVICE,filename=PSout
	ENDIF
	
	FOR coll=0,8 DO BEGIN
		es=0
;		CATCH,es
		IF es NE 0 THEN BEGIN
			es=0
			
			PRINT,'...............................CAUGHT ERROR !......................'
			HELP, CALLS=caller_stack
       			PRINT, 'Error index: ', Error_status
			PRINT, 'Error message:', !ERR_STRING
			PRINT,'Error caller stack:',caller_stack

			GOTO,NEXTPLEASE
		ENDIF
		
		det_index=BYTARR(9)
		det_index(coll)=1		
		pixsiz=pixelsize[coll] * [1.,1.]

		imo->set,det_index_mask=det_index,pixel_size=pixsiz,image_dim=64
		imo->set_no_screen_output
		im=imo->getdata()
	
		IF NOT KEYWORD_SET(SHADE_SURF) THEN BEGIN
			IF NOT KEYWORD_SET(PSout) THEN imo->plot,charsize=charsize,label_size=label_size,xtit='',ytit='',tit='',mar=0.005,grid=10,/LIMB $
			ELSE imo->plot,/iso,charsize=1.0,tit='',mar=0.01,grid=10,/LIMB,legend_loc=0
		ENDIF ELSE BEGIN
			shade_surf,im
		ENDELSE
				
		NEXTPLEASE:
		CATCH,/CANCEL
	ENDFOR

IF KEYWORD_SET(PSout) THEN BEGIN
	DEVICE,/CLOSE
	SET_PLOT,old_device
ENDIF
END


