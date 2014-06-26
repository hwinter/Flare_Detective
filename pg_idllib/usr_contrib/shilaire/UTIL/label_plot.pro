;+
; /XDATA: xypos[0] is actually in data coordinates, otherwise, xypos[0] is the fraction of the xinterval where to put the label (0. to 1.)
; /YDATA: xypos[1] is actually in data coordinates, otherwise, if a positive integer is given for xypos[1], it is assumed to be the position above LOWER border of graph, in integer multiples of the character size.
;		if a negative integer is given for xypos[1], it is assumed to be the position below UPPER border of graph.
; LINE: if set, adds a line before the text..., can also be a float between ]0.,1.], indicating what fraction of the plot's width will the line take. A 1 will be treated as 0.1, a 1. as 1.
; dy_char: vertical spacing between label characters, in multiples of charsize (default is 1), only useful if /YDATA not set...
; POSSIBLE TAGS FOR POLYFILL:
;	-ORIENTATION
;	-dx
;	(-SPACING)
;
;
; Also works on log plots, and on postscript stuff !!!!
;
;
;	EXAMPLES:
;		label_plot, 0.9, -1,'blabla',/LINE, style=1,psym=-7,color=3,charsize=2.0
;		label_plot, 0.03, -2,'blabla',color=2,/POLYFILL
;		label_plot, 0.03, -3,'blabla',color=2,/POLYFILL,/LINE
;		label_plot, 0.03, -4,'blabla',color=2,POLY={ORIENTATION:90},/LINE
;		label_plot, 0.03, -5,'blabla',color=2,POLY={ORIENTATION:0,dx:0.1},/LINE
;		label_plot, 0.03, -6,'blabla',color=2,POLY={ORIENTATION:0},/LINE,charsize=2
;
; HISTORY:
;	PSH, Halloween 2003
;	PSH, 2004/05/18: modified so that if keyword psym is used without keyword line, then the corresponding (single) symbol is plotted.
;	PSH, 2004/08/12: added keyword POLYFILL. By default: solid fill. If /LINE keyword also used, will use linefilling.
;	PSH, 2004/09/24: added keywords /CENTERED & /RIGHT_ALIGNED (LEFT is default): 
;			WARNING: /CENTERED does not (yet) work well in conjunction with either /POLY, /LINE, or psym keywords!
;
;-

PRO label_plot, x, y, text, XDATA=XDATA, YDATA=YDATA, LINE=LINE, dy_char=dy_char, color=color, style=style, psym=psym, charsize=charsize, POLYFILL=POLYFILL, CENTERED=CENTERED, RIGHT_ALIGNED=RIGHT_ALIGNED

	ON_ERROR,2
	IF NOT EXIST(text) THEN text=''
	IF NOT KEYWORD_SET(charsize) THEN charsize=1.0
	ALIGNMENT=0.0
	IF KEYWORD_SET(CENTERED) THEN ALIGNMENT=0.5
	IF KEYWORD_SET(RIGHT_ALIGNED) THEN ALIGNMENT=1.0
	
		
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

	IF KEYWORD_SET(XDATA) THEN BEGIN
		tmp=CONVERT_COORD([x,ll_dev[1]],/DATA,/TO_DEVICE)
		x_dev=tmp[0]
	ENDIF ELSE x_dev=ll_dev[0]+x*(ur_dev[0]-ll_dev[0])
	IF KEYWORD_SET(YDATA) THEN BEGIN
		tmp=CONVERT_COORD([ll_dev[0],y],/DATA,/TO_DEVICE)
		y_dev=tmp[1]
	ENDIF ELSE BEGIN
		IF y GE 0 THEN y_dev=ll_dev[1] ELSE y_dev=ur_dev[1]
		IF KEYWORD_SET(dy_char) THEN dy_char=!D.Y_CH_SIZE*dy_char*FLOAT(charsize) ELSE dy_char=!D.Y_CH_SIZE*1.1*FLOAT(charsize) 
		y_dev=y_dev+y*dy_char	
	ENDELSE

	IF KEYWORD_SET(POLYFILL) THEN BEGIN
		IF tag_exist(POLYFILL,'dx',/QUIET) THEN tmp=POLYFILL.dx ELSE tmp=0.07
		dx_dev=tmp*(ur_dev[0]-ll_dev[0])*(1-2*KEYWORD_SET(RIGHT_ALIGNED))	;!D.X_CH_SIZE*FLOAT(charsize)
		IF tag_exist(POLYFILL,'dy',/QUIET) THEN tmp=POLYFILL.dy ELSE tmp=1
		dy_dev=tmp*!D.Y_CH_SIZE*FLOAT(charsize)
		IF tag_exist(POLYFILL,'ORIENTATION',/QUIET) THEN ori=POLYFILL.ORIENTATION ELSE ori=45
		
		IF KEYWORD_SET(LINE) THEN POLYFILL,x_dev+[0,dx_dev,dx_dev,0],y_dev+[0,0,dy_dev,dy_dev],/DEVICE,color=color,ORIENTATION=ori,linestyle=style $
		ELSE POLYFILL,x_dev+[0,dx_dev,dx_dev,0],y_dev+[0,0,dy_dev,dy_dev],/DEVICE,color=color,linestyle=style
		XYOUTS,x_dev+1.2*dx_dev,y_dev,text, /DEVICE, color=color, charsize=charsize, ALIGNMENT=ALIGNMENT	
	ENDIF ELSE BEGIN
		IF KEYWORD_SET(LINE) THEN BEGIN
			IF datatype(LINE) EQ 'INT' AND LINE EQ 1 THEN LINE=0.1
			linedx_dev=LINE*(ur_dev[0]-ll_dev[0])*(1-2*KEYWORD_SET(RIGHT_ALIGNED))	;*FLOAT(charsize)		
			PLOTS,[x_dev,x_dev+linedx_dev],[y_dev,y_dev], /DEVICE, color=color, linestyle=style, psym=psym
			XYOUTS,x_dev+1.2*linedx_dev,y_dev,text, /DEVICE, color=color, charsize=charsize, ALIGNMENT=ALIGNMENT	
		ENDIF ELSE BEGIN
			IF KEYWORD_SET(psym) THEN BEGIN
				PLOTS,[x_dev],[y_dev], /DEVICE, color=color, linestyle=style, psym=psym
				IF KEYWORD_SET(RIGHT_ALIGNED) THEN txt=text+' ' ELSE txt='  '+text
				XYOUTS,x_dev,y_dev,txt, /DEVICE, color=color, charsize=charsize, ALIGNMENT=ALIGNMENT					
			ENDIF ELSE XYOUTS, x_dev, y_dev, text, /DEVICE, color=color, charsize=charsize, ALIGNMENT=ALIGNMENT
		ENDELSE
	ENDELSE
END
