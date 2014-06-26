;+
; EXAMPLE:
;	obs_time_intv='2002/02/26 '+['10:00','11:00']
;	ptim,psh_goes_get_calm_intv(obs_time_intv,/TEST)
;		...returns -1 if no decay intv could be found...
;	ptim,psh_goes_get_calm_intv('2003/10/28 '+['00:00','24:00'],/TEST)
;
;
;	This routine was designed with the idea that obs_time_intv is the whole flare interval.
;	It will look and return decay time intervals.
;	Will catch also decay intervals between impulsive peaks, when they are longer than ...~2 min.
;	An overlap_intv keyword will just make this routine return a boolean, testing whether we're in decay phase...
;
;	Still needs a bit of parameter tweaking...
;
;
; HISTORY:
;	PSH 2004/08/05 written.
;-

FUNCTION psh_goes_get_calm_intv, obs_time_intv , TEST=TEST, min_intv=min_intv
	
	yoh_time_intv=anytim(obs_time_intv,/yohkoh)
	go=OBJ_NEW('goes')
	go->read,yoh_time_intv[0],yoh_time_intv[1]
	datagoes=go->getdata(utbase=utbase,time=time) 
	
	smoothfactor= 20 < N_ELEMENTS(time)-1	; normally 1 min.
	F=SMOOTH(datagoes[*,0],smoothfactor)
	Fhi=SMOOTH(datagoes[*,1],smoothfactor)
	dFdt=DERIV(time,F)
	dFhidt=DERIV(time,Fhi)
	d2Fdt2=DERIV(time,dFdt)
	d2Fhidt2=DERIV(time,dFhidt)
	dFdt=dFdt/F
	dFhidt=dFhidt/F
	d2Fdt2=d2Fdt2/F
	d2Fhidt2=d2Fhidt2/F
		
	;neg_limit=-2d-8
	pos_limit=5d-4	;i.e. min. exponential rise time is 2000 s.
	;max_slope=5d-10
	
	;ss=WHERE((dFdt GE neg_limit) AND (dFdt LE pos_limit) AND (abs(d2Fdt2) LE max_slope))
	ss=WHERE((dFdt LE pos_limit) AND (dFhidt LE pos_limit/2))
	
	IF KEYWORD_SET(TEST) THEN BEGIN
		!P.MULTI=[0,1,3]
		utplot,time,F,utbase,/YLOG,charsize=2,yrange=[1d-7,1d-3]		
		outplot,time,Fhi,linestyle=2
		IF ss[0] NE -1 THEN outplot,time[ss],F[ss],psym=4,color=150
		utplot,time,dFdt,utbase,yrange=[-1.,1.]*abs(MIN(dFdt)),charsize=2
		outplot,time,dFhidt,linestyle=2
		utplot,time,d2Fdt2,utbase,charsize=2
		outplot,time,d2Fhidt2,linestyle=2
		!P.MULTI=0
	ENDIF

	IF ss[0] EQ -1 THEN RETURN,-1	
	good_ss=get_contiguous_ss(ss,min_length=fcheck(min_intv)/3)
	IF good_ss[0] NE -1 THEN RETURN, time[ss[good_ss]]+anytim(utbase) 	
END


