;============================================================================
;+
; PROJECT:  PSH's PhD studies
;
; NAME:  rag_drift_rate.pro
;
; PURPOSE:  calculates 'drift rate' of input array
;
; CALLING SEQUENCE: 
;
; INPUTS:
;
; OUTPUTS:  
;
; OPTIONAL OUTPUTS:  
;
; Calls:
;
; COMMON BLOCKS: None
;
; PROCEDURE:
;
; RESTRICTIONS:
;
; SIDE EFFECTS:
;
; EXAMPLES:
;	time_intv='2001/09/30 '+['09:40:00','09:40:45']
;	freq_intv=[2350,3700]
;	rag_drift_rate(time_intv,freq_intv,/display,ADDPTS=3)
;
; HISTORY:
;       Written Pascal Saint-Hilaire, 2001/11/15.
;		Made ~OBSELETE the following day by rapp_drift_rate.pro (except the neat 'drift_rate' routine)
; MODIFICATIONS:
;
;-
;============================================================================
FUNCTION return_rag_data,time_intv,freq_intv,MHZpPIX=MHZpPIX,SECpPIX=SECpPIX

	image=rag_get_array(time_intv,freq_intv,xaxis=xaxis,yaxis=yaxis)
	temp=N_ELEMENTS(yaxis)	
	MHZpPIX=(yaxis(temp-1)-yaxis(0))/DOUBLE(temp)
		print,MHZpPIX	
	temp=N_ELEMENTS(xaxis)
	SECpPIX=(xaxis(temp-1)-xaxis(0))/DOUBLE(temp)
		print,SECpPIX
		
	RETURN,image
END
;============================================================================
PRO drift_rate,image,ref=ref, addpts=addpts,	display=display,	$
			slope,sigma

; this routine does the whole job on a 'per pixel' basis
; only conversion is needed afterwards, i.e. multiply obtained slope
; by the number of MHz/pixel, divide by the number of seconds/pixel

; the 'addpts' is the number of additional points in each interval

nx=N_ELEMENTS(image(*,0))
ny=N_ELEMENTS(image(0,*))
IF NOT KEYWORD_SET(ref) THEN ref=ny/2
IF NOT KEYWORD_SET(addpts) THEN addpts=0

IF KEYWORD_SET(display) THEN BEGIN
	wdef,0
	plot_image,congrid(image,512,512)
ENDIF

correl1d,image, DINDGEN(nx), ref, ccImage, ccXaxis

IF KEYWORD_SET(display) THEN BEGIN
	wdef,1
	plot_image,congrid(ccImage,512,512)
ENDIF


maxima=DBLARR(ny)	; X position of the maxima of the crosscorrelation at the Y line
IF addpts NE 0 THEN BEGIN ; spline line by line, find maxima...
	ccNx=N_ELEMENTS(ccImage(*,0))
	N=ccNx*(addpts+1) ; N is number of points after spline
	t=DINDGEN(N)*ccNx/N ; t is new x-axis
	FOR j=0,ny-1 DO BEGIN
		z=SPLINE(DINDGEN(ccNx),ccImage(*,j),t)		
		temp=max(z,ss)
		maxima(j)=DOUBLE(ss)/(addpts+1)  ; normalize it to original pixel size, because spline adds points
		;print,maxima(j),j
	ENDFOR
ENDIF ELSE BEGIN	; do the work directly on the ccImage
	FOR j=0,ny-1 DO BEGIN
		temp=max(ccImage(*,j),ss)
		maxima(j)=ss
		;print,maxima(j),j
	ENDFOR
ENDELSE


IF KEYWORD_SET(display) THEN BEGIN
	oplot,maxima*256/nx,LINDGEN(ny)*512/ny,psym=-7,color=0
ENDIF




;NOW, 'simple' linear regression with the array of 'maxima':

slope=REGRESS(maxima,DINDGEN(ny),/DOUBLE,SIGMA=sigma)
slope=slope/1.
sigma=sigma/1.
END
;============================================================================


PRO rag_drift_rate,time_intv,freq_intv,ELIM=ELIM,BACKSUB=BACKSUB,DISPLAY=DISPLAY,ADDPTS=ADDPTS 	,$
			SLOPE=SLOPE,SIGMA=SIGMA
	
	data=return_rag_data(time_intv,freq_intv,MHZpPIX=MHZpPIX,SECpPIX=SECpPIX)
	;MHZpPIX=1.
	;SECpPIX=1.
	;data=DBLARR(5,5)
	;data(0,4)=1.
	;data(1,3)=1.
	;data(2,2)=1.
	;data(3,1)=1.
	;data(4,0)=1.
	;data=congrid(data,50,50,/interp)
	
	drift_rate,data,slope,sigma,display=DISPLAY,addpts=ADDPTS	;,ref=...

	SLOPE=slope*MHZpPIX/SECpPIX
	SIGMA=sigma*abs(MHZpPIX)/SECpPIX

	IF KEYWORD_SET(DISPLAY) THEN BEGIN
		PRINT, ' Drift rate is : '+STRN(SLOPE)+' +/- '+STRN(SIGMA)+' MHz/s '
	ENDIF
END



; ELIMWRONGCHANNEL
; CONSTBACKSUB
; LOW/HIGH-PASS FILTERING...






