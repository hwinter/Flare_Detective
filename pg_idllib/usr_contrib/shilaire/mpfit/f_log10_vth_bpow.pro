; par=[EM,T,Eph_TO,gamma,F50]
;
;

FUNCTION f_log10_vth_bpow, E, par
	g1=1.5d
	epivot=50d
	
	res=par[4] * (E/epivot)^(-par[3])
	ss=WHERE(E LE par[2])
	IF ss[0] NE -1 THEN res[ss]=par[4] * (par[2]/epivot)^(-par[3]) * (E[ss]/par[2])^(-g1)
	RETURN,ALOG10(res+f_vth(E,par[0:1]))
END
