;PSH 2003/02/08
; enter a date_intv, returns a 2-d array of start & end anytimes where our local GOES db has no coverage...
;
; EXAMPLE:
;	list=list_holes_in_goes_coverage(['2002/02/13','2003/02/01'])

FUNCTION list_holes_in_goes_coverage, date_intv

	nbr_days=CEIL( (anytim(date_intv[1],/date)-anytim(date_intv[0],/date))/86400. )
	list=-1
		
	FOR i=0L, nbr_days-1 DO BEGIN
		newintv=anytim(date_intv[0],/date)+i*86400.+[0,86399.]
		rd_goes,goestime,goesdata,trange=anytim(newintv,/yoh)	;,/goes8
		IF datatype(goesdata) EQ 'UND' THEN BEGIN
			IF datatype(list) EQ 'INT' THEN list=anytim(newintv,/ECS) ELSE list=[[list],[anytim(newintv,/ECS)]]
		ENDIF
	ENDFOR
	RETURN,list
END
