;+
; EXAMPLE:
;	obs_time_intv='2002/02/26 '+['10:00','11:00']
;	ptim,psh_goes_get_decay_intv(obs_time_intv,/TEST)
;	ptim,psh_goes_get_decay_intv('2003/10/28 '+['00:00','24:00'],/TEST)
;		...returns -1 if no decay intv could be found...
;
;
;	This routine was designed with the idea that obs_time_intv is the whole flare interval.
;	It will look and return for the last decay time interval.
;	
; PLANNED IMPROVEMENTS:
;	Will catch also decay intervals between impulsive peaks, when they are longer than ...~2 min.
;	An overlap_intv keyword will just make this routine return a boolean, testing whether we're in decay phase...
;
; HISTORY:
;	PSH 2004/08/05 written.
;-

FUNCTION psh_goes_get_decay_intv, obs_time_intv , TEST=TEST
	
	yoh_time_intv=anytim(obs_time_intv,/yohkoh)
	go=OBJ_NEW('goes')
	go->read,yoh_time_intv[0],yoh_time_intv[1]
	datagoes=go->getdata(utbase=utbase,time=time) 
	
	smoothfactor= 20 < (N_ELEMENTS(time)-1)	; normally 1 min.
	F=SMOOTH(datagoes[*,0],smoothfactor)
	dFdt=DERIV(time,F)/F
	
	neg_limit=-1d-3
	pos_limit=1d-7
	
	ss=WHERE(dFdt GE neg_limit)	; AND (dFdt LE pos_limit))
	IF N_ELEMENTS(ss) EQ 1 THEN RETURN,-1
	tmp=get_contiguous_ss(ss)
	IF N_ELEMENTS(tmp) EQ 1 THEN RETURN,-1
	last_intv_ss=ss[tmp[0,N_ELEMENTS(tmp[0,*])-1]:*]
	
	IF KEYWORD_SET(TEST) THEN BEGIN
		!P.MULTI=[0,1,2]
		clear_utplot
		utplot,time,datagoes[*,0],utbase,/YLOG,charsize=2
		outplot,time[ss],datagoes[ss,0],psym=4,color=150
		outplot,time[last_intv_ss],datagoes[last_intv_ss,0],psym=4,color=50
		utplot,time,dFdt,utbase,charsize=2,yrange=[-1,1]*0.001	;,yrange=[-1.,1.]*abs(MIN(dFdt))
		!P.MULTI=0
	ENDIF
	;just return the last time_intv...	
	RETURN,time[ss[tmp[*,N_ELEMENTS(tmp[0,*])-1]]]+anytim(utbase)
END


