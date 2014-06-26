; PSH 2001/05/01
;
; this function converts an anytim format date to a format directly readable
;	by ORACLE, i.e. : yyyy-mm-dd hh:mm:ss,xxx	where xxx is milliseconds
;
; intime can be an array of times...
;
;
;	Hacked on 2002/03/11 : if intime is -9999., then outputs -9999	(PSH)
;




FUNCTION anytim2oracle,intime

outtime=anytim(intime,/ECS)

FOR i=0,N_ELEMENTS(intime)-1 DO BEGIN
	bla=outtime(i)
	STRPUT,bla,'-',4
	STRPUT,bla,'-',7
	STRPUT,bla,',',19
	outtime(i)=bla
	IF grep('-9999',strn(intime(i))) ne '' then outtime(i)='-9999'
ENDFOR
RETURN,outtime
END
