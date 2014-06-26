;works also for arrays[2,*] of anytim !
;if an interval is smaller tha a single spin period, that interval is increased to include a single spin_period.

FUNCTION to_multiples_of_spin_period, time_intv, spin_period=spin_period
	
	IF N_ELEMENTS(time_intv) EQ 1 THEN RETURN,-1
	n_intv=N_ELEMENTS(time_intv[0,*])
	res=-1
		
	FOR i=0,n_intv-1 DO BEGIN
		IF KEYWORD_SET(spin_period) THEN period=spin_period ELSE period=rhessi_get_spin_period(time_intv[*,i],/DEF)
		tmp=anytim(time_intv[*,i])
		deltat=FIX((tmp[1]-tmp[0])/period)*period
		IF deltat LT spin_period THEN deltat=spin_period
		newtmp=tmp[0]+[0.,deltat]
		IF N_ELEMENTS(res) EQ 1 THEN res=newtmp ELSE res=[[res],[newtmp]]	
	ENDFOR	
	RETURN,res
END
