; PSH 2001/11/20
;
; This routine will take a lightcurve from Yohkoh HXT, and spline it
; according to the time-concurrent Phoenix data. In the end, a text
; file is created, that can be read by ragview.
;
; EXAMPLE:
;	time_intv='2000/08/25 '+['14:27:00','14:34:00']
;	hinfil='/global/lepus/usr/users/shilaire/YOHKOH/2000_08_25/hda000825.1344'
;	hchannel=1	; from 1 to 4
;	rapp_hxtlc, time_intv, hinfil, hchannel
;==========================================================================================

PRO rapp_hxtlc, time_intv, hinfil, hchannel, outfil=outfil,$
	 display=display, NOHEADER=NOHEADER

IF NOT exist(outfil) THEN outfil='hxt_lc.dat'

rd_xda,hinfil,-1,hindex,hdata
ave = ave_cts(hindex,hdata,time=time)
S=size(time)
newtime=REFORM(time,S[1]*S[2])
newave=REFORM(ave,4,S[1]*S[2])
ave_ch=newave(hchannel-1,*)
IF KEYWORD_SET(display) THEN utplot,newtime,ave_ch, hindex(0)

;; convert to ragtimes (i.e. seconds from midnight) 
basetime=DOUBLE(hindex(0).gen.time)/1000.
times=newtime+basetime

;;get ragdata
ragdata=rapp_get_array(time_intv, xaxis=xaxis)

; spline HXT data to the rag data xaxis size
hxtlc=SPLINE(times,ave_ch,xaxis)

OPENW,lun1,outfil,/GET_LUN
IF NOT KEYWORD_SET(NOHEADER) THEN BEGIN
	PRINTF,lun1,'HXT channel (1-4):'+STRN(hchannel)+' lightcurve. '
	PRINTF,lun1,anytim(time_intv(0),/ECS)+' to '+anytim(time_intv(1),/ECS)
ENDIF	
FOR i=0,N_ELEMENTS(xaxis)-1 DO PRINTF,lun1,STRN(hxtlc(i))
CLOSE,lun1

END


