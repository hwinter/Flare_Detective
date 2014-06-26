;
;List of procedures, functions to be compiled at idl startup
;
;

PRO pg_compilelist

resolve_routine,'mpfit',/either
resolve_routine,'tnmin',/either

RETURN

END
