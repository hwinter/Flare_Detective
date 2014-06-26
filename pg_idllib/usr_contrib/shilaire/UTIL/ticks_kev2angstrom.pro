

FUNCTION ticks_kev2angstrom, axis, index, value
	newval=12.42/value
	RETURN,STRING(newval,FORMAT='(f10.3)')
END
