

FUNCTION psh_time2dir, times
	res=anytim(times,/ECS)
		
	FOR i=0L,N_ELEMENTS(res)-1 DO res[i]=STRMID(res[i],0,10)+'/'
	RETURN,res
END
