;	.r extract_trace_image20030104

;GOTO,NEXT1

set_plot,'Z'
psh_win,501
LOADCT,1
;files='TEMP/tri20010615.'+['09','10','11']+'00'
files='TEMP/tri20010615.1000'
n_frames=[195,593,330]
;search ss of interest (forget time ranges, for now...)
nbr=0
cube='bla'
FOR i=0L,N_ELEMENTS(files)-1 DO BEGIN
	;FOR j=0L,n_frames[i]-1 DO BEGIN
	FOR j=40L,350 DO BEGIN	
		read_trace,files[i],j,index
		IF ((index.WAVE_LEN EQ '195') AND (index.NAXIS1 EQ 768) AND (anytim(index.date_obs,/time) ge anytim('10:08:33',/time)) AND (anytim(index.date_obs,/time) le anytim('10:25:00',/time)) AND (index.SHT_MDUR gt 3.5)) THEN BEGIN
			nbr=nbr+1
			read_trace,files[i],j,index,img
			IF index.SHT_MDUR GT 0 THEN BEGIN
				;;trace_prep,index,data,outindex,outdata,/wave2point,/unspike,/destreak,/deripple	;,/normalize
				img=tracedespike(img,stat=2)
				img=FLOAT(img[0:500,0:500])/index.SHT_MDUR
				img=alog(1.> img < 30.)
				TVSCL,img
				XYOUTS,30,10,anytim(index.date_obs,/ECS),/DEV				
				img=TVRD()
				IF datatype(cube) EQ 'STR' THEN cube=img ELSE cube=[[[cube]],[[img]]]	
			ENDIF
		ENDIF
		PRINT,i,j,nbr
	ENDFOR
ENDFOR
PRINT,nbr
DEVICE,/close
SAVE,cube
SET_PLOT,'X'
END

