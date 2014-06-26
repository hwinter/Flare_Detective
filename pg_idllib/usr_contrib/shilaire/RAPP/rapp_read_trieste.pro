;INPUT:
;	file:
;	freq: is between 1 and 6
;	/REMOVE_BAD: if this keyword is set, will remove all values below 1.
;OUTPUT:
;	times: times array (in anytim format)
;	lc: lightcurve array. If /REMOVE_BAD was set, qquals -1 if all values are bad.
;EXAMPLE:
;	rapp_read_trieste, file, 1, times,lc,/REMOVE
;	utplot,times,lc
;--------------------------------------------------------------------------------------------
PRO rapp_read_trieste, file, freq, REMOVE_BAD=REMOVE_BAD, $
	times, lc

	data=mrdfits(file,1,header)
	addchr=strn(STRUPCASE(freq))
	
	freqname=sxpar(header,'TTYPE'+addchr)	
	PRINT,'.....getting '+freqname
	tzero=sxpar(header,'TZERO'+addchr)	
	tscale=sxpar(header,'TSCAL'+addchr)	
	dateobs=sxpar(header,'DATE-OBS')
	lc=tzero+tscale*data.(freq-1)
	anydateobs=STRMID(dateobs,0,4)+'/'+STRMID(dateobs,5,2)+'/'+STRMID(dateobs,8,2)+' '+STRMID(dateobs,11,2)+':'+STRMID(dateobs,14,2)+':'+STRMID(dateobs,17,2)
	times=anytim(anydateobs)+DINDGEN(N_ELEMENTS(lc))	; assumes 1s bins !!!!
	IF KEYWORD_SET(REMOVE_BAD) THEN BEGIN
		ss=WHERE(lc GE 1.)
		IF ss[0] EQ -1 THEN lc=-1 ELSE BEGIN
			times=times[ss]
			lc=lc[ss]
		ENDELSE
	ENDIF
END

