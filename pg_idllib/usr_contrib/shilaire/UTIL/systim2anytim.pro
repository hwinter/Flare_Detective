;	PSH 2002/03/17
;
;
;
;
;	Converts system time (as given by IDL' SYSTIME() function)
;	into ANYTIM time format.
;
;	If no parameter is passed, current UTC time is assumed.
;
;	EX:
;		print,systim2anytim(/ECS)
;		print,systim2anytim()
;		print,systim2anytim('Sun Mar 17 15:23:37 2002',/ECS)
;
;




FUNCTION systim2anytim,intim,_extra=_extra

	IF N_PARAMS() EQ 0 THEN intim=SYSTIME()

	tokens=rsi_strsplit(intim,/EXTRACT)
	
	month=tokens(1)
	day=tokens(2)
	tim=tokens(3)
	year=tokens(4)
	
	RETURN,anytim(year+'-'+month+'-'+day+' '+tim,_extra=_extra)	

END
