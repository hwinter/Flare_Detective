; PSH 2001/11/20
;
; This routine will take a lightcurve from CGRO-BATSE, and spline it
; according to the time-concurrent Phoenix data. In the end, a text
; file is created, that can be read by ragview.
;
; EXAMPLE:
;	time_intv='1999/09/08 '+['12:13:00','12:15:40']
;	rapp_batselc, time_intv
;==========================================================================================

PRO rapp_batselc, time_intv, channel=channel, outfil=outfil,$
	 display=display, NOHEADER=NOHEADER

IF NOT exist(outfil) THEN outfil='batse_lc.dat'

sttim=anytim(time_intv(0),/yoh)
entim=anytim(time_intv(1),/yoh)
rd_gbl, sttim, entim, gbl, status=status
IF status gt 0 THEN PRINT,'No data available for the time period !!!'

;; convert to ragtimes (i.e. seconds from midnight) 
times=DOUBLE(gbl.time)/1000.

;;choose BATSE channels:
IF NOT KEYWORD_SET(channel) THEN batse_cts=DOUBLE(gbl.channel1)+DOUBLE(gbl.channel2) $
ELSE BEGIN
	IF channel EQ 1 THEN batse_cts=DOUBLE(gbl.channel1)
	IF channel EQ 2 THEN batse_cts=DOUBLE(gbl.channel2)
ENDELSE

IF KEYWORD_SET(display) THEN utplot,times,batse_cts

;;get ragdata
ragdata=rapp_get_array(time_intv, xaxis=xaxis)

; spline BTASE data to the rag data xaxis size

batselc=SPLINE(times,batse_cts,xaxis)

OPENW,lun1,outfil,/GET_LUN
IF NOT KEYWORD_SET(NOHEADER) THEN BEGIN
	PRINTF,lun1,'BATSE lightcurve'
	PRINTF,lun1,anytim(time_intv(0),/ECS)+' to '+anytim(time_intv(1),/ECS)
ENDIF	
FOR i=0,N_ELEMENTS(xaxis)-1 DO PRINTF,lun1,STRN(batselc(i))
CLOSE,lun1

END


