;PSH 2004/02/13
;
; Takes all anytim keywords...
;
; EXAMPLE:
;	PRINT,ragfile2time(FINDFILE('/ftp/pub/rag/callisto/observations/2003/10/27/*.fit.gz'),/ECS)
;

FUNCTION ragfile2time, files, _extra=_extra
	FOR i=0L, N_ELEMENTS(files)-1 DO BEGIN
		BREAK_FILE, files[i], DISK_LOG, DIR, FILNAM, EXT, FVERSION, NODE
		newtim=anytim(STRMID(FILNAM,0,4)+'/'+STRMID(FILNAM,4,2)+'/'+STRMID(FILNAM,6,2)+' '+STRMID(FILNAM,8,2)+':'+STRMID(FILNAM,10,2)+':'+STRMID(FILNAM,12,2))
		IF i EQ 0 THEN res=newtim ELSE res=[res,newtim]		
	ENDFOR
	RETURN,anytim(res,_extra=_extra)
END


