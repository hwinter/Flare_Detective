;--------------------------------------------
PRO catch_testor_sub
	CATCH,es
	IF es NE 0 THEN GOTO, THEEND1
;bla=bla[2]
	PRINT,'Begin of end of testor_sub'
	THEEND1:
	PRINT,'End of testor_sub'
END
;--------------------------------------------
PRO catch_testor
	CATCH,es
	IF es NE 0 THEN GOTO, THEEND2

;bla=bla[2]
	catch_testor_sub
bla=bla[2]

	PRINT,'Begin of end of testor'
	THEEND2:
	PRINT,'End of testor'
END
;--------------------------------------------
