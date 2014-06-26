;
; If /DEVICE not set, [x,y] are DATA coordinates of lower left corner of label.
; If /DEVICE is set:
; 	xypos[0] is the fraction of the xinterval where to put the label (0. to 1.)
; 	If a positive integer is given for xypos[1], it is assumed to be the position above LOWER border of graph
; 	If a negative integer is given for xypos[1], it is assumed to be the position below UPPER border of graph
;	IF /NOLINE is set, then only the text is displayed...
;
; Also works on log plots, and on postscript stuff !!!!
;
;
;	EXAMPLE:
;		plot_label,[1000,20],'blabla'
;		plot_label,[0.9,-1],'blabla',/DEV
;


PRO plot_label, xypos, text, DEVICE=DEVICE, linedx=linedx, dy=dy, color=color, linestyle=linestyle, psym=psym, charsize=charsize, NOLINE=NOLINE

	ON_ERROR,2
	IF NOT EXIST(text) THEN text=''
	IF NOT KEYWORD_SET(charsize) THEN charsize=1.0
	IF NOT KEYWORD_SET(DEVICE) THEN BEGIN 
		IF NOT KEYWORD_SET(linedx) THEN linedx=(!X.CRANGE[1]-!X.CRANGE[0])/10.*FLOAT(charsize)
		IF NOT KEYWORD_SET(NOLINE) THEN BEGIN
			PLOTS,xypos[0]+[0,linedx],xypos[1]*[1,1], color=color, linestyle=linestyle, psym=psym
			XYOUTS,xypos[0]+1.2*linedx,xypos[1],text, color=color, charsize=charsize
		ENDIF ELSE BEGIN
			XYOUTS,xypos[0],xypos[1],text, color=color, charsize=charsize			
		ENDELSE
	ENDIF ELSE BEGIN
		IF NOT KEYWORD_SET(dy) THEN dy=!D.Y_CH_SIZE*1.1*FLOAT(charsize)
		
		ll_data=DBLARR(2)
		ur_data=DBLARR(2)
		IF !X.TYPE EQ 1 THEN BEGIN
			ll_data[0]=10^!X.CRANGE[0]
			ur_data[0]=10^!X.CRANGE[1]
		ENDIF ELSE BEGIN		
			ll_data[0]=!X.CRANGE[0]
			ur_data[0]=!X.CRANGE[1]
		ENDELSE
		IF !Y.TYPE EQ 1 THEN BEGIN
			ll_data[1]=10^!Y.CRANGE[0]
			ur_data[1]=10^!Y.CRANGE[1]
		ENDIF ELSE BEGIN		
			ll_data[1]=!Y.CRANGE[0]
			ur_data[1]=!Y.CRANGE[1]
		ENDELSE		
		ll_dev=CONVERT_COORD(ll_data,/DATA,/TO_DEVICE)
		ur_dev=CONVERT_COORD(ur_data,/DATA,/TO_DEVICE)		
		x=ll_dev[0]+xypos[0]*(ur_dev[0]-ll_dev[0])
		IF xypos[1] GE 0 THEN y=ll_dev[1] ELSE y=ur_dev[1]
		y=y+xypos[1]*dy
	
		IF NOT KEYWORD_SET(linedx) THEN linedx=(ur_dev[0]-ll_dev[0])/10.	;*FLOAT(charsize)
		IF NOT KEYWORD_SET(NOLINE) THEN BEGIN
			PLOTS,[x,x+linedx],[y,y], /DEVICE, color=color, linestyle=linestyle, psym=psym
			XYOUTS,x+1.2*linedx,y,text, /DEVICE, color=color, charsize=charsize
		ENDIF ELSE XYOUTS,x,y,text, /DEVICE, color=color, charsize=charsize
	ENDELSE


END
