;	 Pascal Saint-Hilaire	2001/12/16
;		shilaire@astro.phys.ethz.ch OR psainth@hotmail.com
;
;	PURPOSE: returns 1 if number is in range, 0 otherwise
;
;	EXAMPLE: 
;		print, is_in_range(3.4, [-5,7])
;


FUNCTION is_in_range, number, range
	tmpnumber=DOUBLE(number)	; tmp wouldn't be needed here, but heck...
	tmprange=DOUBLE(range)
	IF ( (tmpnumber LT tmprange(0)) OR (tmpnumber GT tmprange(1)) ) THEN RETURN,0 ELSE RETURN,1
END
