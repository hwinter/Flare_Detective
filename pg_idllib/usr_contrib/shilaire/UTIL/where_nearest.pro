; PSH 2004/02/16
;
FUNCTION where_nearest, inarr, value
	RETURN, (SORT(abs(inarr-value)))[0]
END
