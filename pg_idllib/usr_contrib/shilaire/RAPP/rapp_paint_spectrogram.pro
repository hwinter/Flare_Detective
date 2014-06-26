;+
;NAME:
; 	rapp_paint_spectrogram.pro
;PROJECT:
; 	ETHZ Radio Astronomy
;CATEGORY:
; 	Utility
;PURPOSE:
;
;CALLING SEQUENCE:
; rapp_paint_spectrogram,image,xaxis,yaxis,LOG=LOG,Zbuffer=Zbuffer
;
;INPUT:
;
;OPTIONAL INPUT:
;
;KEYWORD INPUT:
;	/LOG : to display intensity in log scale
;	/Zbuffer
;	/NOLABELS
;
;OUTPUT:
; a Phoenix-2 spectrogram image, in LINEAR SFU scale (for intensities) or % circular polarization (negative = left)
;
;KEYWORD OUTPUT:
;
;CALLS
;	rapp_get_spectrogram.pro
;
;EXAMPLE:
;
;HISTORY:
;	Pascal Saint-Hilaire, 2002/04/01 created
;		shilaire@astro.phys.ethz.ch
;
;-

;==============================================================================================
PRO rapp_paint_spectrogram,data,xaxis,yaxis,Zbuffer=Zbuffer,LOG=LOG,NOLABELS=NOLABELS,DESPIKE=DESPIKE,HMS=HMS

	charsiz=1.2
	IF KEYWORD_SET(DESPIKE) THEN img=tracedespike(data) ELSE img=data

	imgmin=min(img,max=imgmax)
	IF KEYWORD_SET(LOG) THEN BEGIN
		ss=WHERE(img LT 1.)
		img(ss)=1.
		img=alog10(img)
		imgmin=1.
	ENDIF 
	
	;IF KEYWORD_SET(Zbuffer) THEN z_show_image,img,xaxis,yaxis,/hms,imageoffset=0 ELSE show_image,img,xaxis,yaxis,/hms,imageoffset=0
	IF KEYWORD_SET(Zbuffer) THEN z_show_image,img,xaxis,yaxis,imageoffset=0,HMS=HMS ELSE show_image,img,xaxis,yaxis,imageoffset=0,HMS=HMS
	
	IF NOT KEYWORD_SET(NOLABELS) THEN BEGIN
		XYOUTS,/DEV,165,545,strn(imgmin,format='(f10.1)')
		XYOUTS,/DEV,405,545,strn(imgmax,format='(f10.1)')
		IF KEYWORD_SET(LOG) THEN XYOUTS,/DEV,270,545,'SFUs (log scale)' ELSE XYOUTS,/DEV,300,545,'SFUs'
		xyouts,5,550,'MHz',/dev,charsiz=CHARSIZ
		XYOUTS,/dev,450,580,'Phoenix-2',charsiz=charsiz
		XYOUTS,/dev,450,565,'Radio Spectrogram',charsiz=charsiz
		XYOUTS,/dev,450,550,'ETH Zurich',charsiz=charsiz
	ENDIF
END
;==============================================================================================

