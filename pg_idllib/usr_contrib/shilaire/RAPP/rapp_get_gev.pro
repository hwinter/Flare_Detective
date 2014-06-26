; This routine gets GOES event (flare start, peak, end times, duration, location (Heliocentric coord.), NOAA AR, radio fluxes (2.7, 8.8, 15.4 GHz) and X-ray class for an input time interval.
; Returns -1 if nothing is found. Otherwise returns an array of structure (one per flare).
;
; PSH 2004/09/11
;


FUNCTION rapp_get_gev, time_intv
	gev=get_gev( anytim(time_intv[0],/yoh) , anytim(time_intv[1],/yoh) )
	IF datatype(gev) EQ 'STR' THEN RETURN,-1

	gev_stc={	CLASS:		'A0.0',$
			MAXFLUX:	-1d,$
			START_TIME:	'bla',$
			PEAK_TIME:	'bla',$
			END_TIME:	'bla',$
			DURATION:	-1d,$
			LOCATION:	[0.,0.],$
			NOAA_AR:	-1,$
			F2700:		-1,$
			F8800:		-1,$
			F15400:		-1}
	
	out=REPLICATE(gev_stc,N_ELEMENTS(gev))
	FOR i=0L,N_ELEMENTS(gev)-1 DO BEGIN
		out[i].CLASS=STRING(gev[i].ST$CLASS[0])+STRING(gev[i].ST$CLASS[1])+STRING(gev[i].ST$CLASS[2])+STRING(gev[i].ST$CLASS[3])
		CASE STRING(gev[i].ST$CLASS[0]) OF
			'A': baseflux=1d-8
			'B': baseflux=1d-7
			'C': baseflux=1d-6
			'M': baseflux=1d-5
			'X': baseflux=1d-4
			ELSE: baseflux=0d
		ENDCASE			
		out[i].MAXFLUX=baseflux*DOUBLE(STRMID(out[i].CLASS,1))
		out[i].START_TIME=anytim([gev[i].TIME,gev[i].DAY],/ECS)
		out[i].PEAK_TIME=anytim(anytim([gev[i].TIME,gev[i].DAY])+gev[i].PEAK,/ECS)
		out[i].END_TIME=anytim(anytim([gev[i].TIME,gev[i].DAY])+gev[i].DURATION,/ECS)
		out[i].DURATION=gev[i].DURATION
		IF ((gev[i].LOCATION[0] EQ -999) AND (gev[i].LOCATION[1] EQ -999)) THEN out[i].LOCATION=[!VALUES.F_NAN,!VALUES.F_NAN] ELSE out[i].LOCATION=conv_h2a(gev[i].LOCATION,out[i].PEAK_TIME)
		out[i].NOAA_AR=gev[i].NOAA
		out[i].F2700=gev[i].RADIO[0]
		out[i].F8800=gev[i].RADIO[1]
		out[i].F15400=gev[i].RADIO[2]		
	ENDFOR		
	;now, take only those within time_intv (as we might have taken more...)
	good_ss=WHERE((anytim(out.END_TIME) GE anytim(time_intv[0])) AND (anytim(out.START_TIME) LE anytim(time_intv[1])))
	IF good_ss[0] EQ -1 THEN RETURN,-1 ELSE RETURN,out[good_ss]
END
