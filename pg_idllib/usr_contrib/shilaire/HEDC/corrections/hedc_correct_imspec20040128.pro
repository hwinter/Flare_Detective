; RUN THIS SCRIPT AS USER "hedc"... ('cause .png files have w-- permissions):
;	../shilaire/bin/rappidl55
;
; hedc_correct_imspec20040128, 'HXS401141558'
; eventcodes=['HXS401141558','HXS401150629','HXS401160119','HXS401170342','HXS401170756','HXS401170915','HXS401170943','HXS401171248','HXS401172048','HXS401180019','HXS401181354','HXS401182029','HXS401200020','HXS401200124','HXS401200157','HXS401200201','HXS401200500','HXS401200508','HXS401200751','HXS401210510']
; hedc_correct_imspec20040128,  eventcodes
;
;


PRO hedc_correct_imspec20040128, eventcodes

	basecmd='rsh hercules java -cp ".:/global/hercules/users/hedc/dm/classes/dm.jar:/global/hercules/users/hedc/dm/classes/sc_lib.jar::/global/hercules/users/shilaire/HEDC/util" '
	basearchpath='/global/hercules/data2/archive/'
	
	SET_PLOT,'Z'
	FOR i=0L,N_ELEMENTS(eventcodes)-1 DO BEGIN
		ok=1
		;first, find file:
		rootfilename='HEDC_DP_imsp_'+eventcodes[i]		
		
		;finding fitsfilepath:
			cmd=basecmd+'query1 TXT_FIL_NAME eq '+rootfilename+'.fits FKY_FIL_ARC_ID'
			SPAWN,cmd,res,err						
			IF res[0] NE '' THEN BEGIN
				cmd=basecmd+'query1 LKY_ARC_ID eq '+res[0]+' TXT_ARC_PATH'				
				SPAWN,cmd,res,err
				IF res[0] NE '' THEN fitsfilepath=basearchpath+res[0]+rootfilename+'.fits' ELSE ok=0
			ENDIF ELSE ok=0
		
		;finding pngfilepath:
			cmd=basecmd+'query1 TXT_IMG_NAME eq '+rootfilename+'.png FKY_IMG_ARC_ID'
			SPAWN,cmd,res,err						
			IF res[0] NE '' THEN BEGIN
				cmd=basecmd+'query1 LKY_ARC_ID eq '+res[0]+' TXT_ARC_PATH'				
				SPAWN,cmd,res,err
				IF res[0] NE '' THEN pngfilepath='/global/hercules/data2/archive/'+res[0]+rootfilename+'.png' ELSE ok=0
			ENDIF ELSE ok=0
		
		;IF all OK, go on:
			IF ok THEN BEGIN
				PRINT,'OK so far: found .fits and .png file locations for '+rootfilename+'... redoing imspec...'
				hedc_imspec, -1, [1,8,12],fitsfile=fitsfilepath,SKIP=2
				TVLCT,r,g,b,/GET
				WRITE_PNG,pngfilepath,TVRD(),r,g,b
			ENDIF ELSE PRINT,'Not ok with '+eventcodes[i]+'...'
	ENDFOR
	DEVICE,/CLOSE
END

