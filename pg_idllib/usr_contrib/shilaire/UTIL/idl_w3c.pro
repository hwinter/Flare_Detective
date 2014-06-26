;+
;       PSH 2001/12/21
;
;       PURPOSE:
;       To return the HTML content of a web page, using the http protocol.
;
;
;       RESTRICTIONS:
;               needs IDL >= 5.4 !!!
;
;       INPUTS:
;			url:  an url, ex: 'www.hedc.ethz.ch/'	(the last "/" is very important, in case index.html is assumed...)
;
;		OPTIONAL INPUTS:
;			
;		OUTPUTS:
;			*	-1 if socket was not established
;			*	array of strings if everything went all right.
;
;       EXAMPLE:
;			text=idl_w3c('www.astro.phys.ethz.ch','/index.html')
;			text=idl_w3c('www.astro.phys.ethz.ch','/staff/staff_nf.html')
;
;-




FUNCTION idl_w3c,server,file
	
	;=====================================================================================
	;OPTIMIZATION CONSTANTS:
		NLINES=500	; initial guess as to the number of lines the HTML page has.
					; better approximate by excess, as whenever NLINES is not high enough,
					; I redo a query with a bigger NLINES...
		NULLSTRING='@=@'
		FACTOR=2
	;=====================================================================================


		NLINES=NLINES/FACTOR
	Smaller: NLINES=FACTOR*NLINES		; I could have more than a factor 2...
		print,'Getting page...'

		received=REPLICATE(NULLSTRING,NLINES)
		socket_err=0        
		SOCKET,lun,server,80,/GET_LUN,err=socket_err
        IF socket_err eq 0 THEN BEGIN
				ON_IOERROR, Bigger				
				sent='GET '+file
				PRINTF,lun,sent
				READF,lun,received
				FREE_LUN,lun	;if I got here, then I didn't have an error, 
				GOTO,Smaller	;which means I didn't get everything (the 'received' wasn't big enough)
        ENDIF ELSE BEGIN
			PRINT,'============= Socket not established ! ==============='
			RETURN,-1
		ENDELSE
		
	Bigger: print,'Got everything !'
		; OK, if I got here, it's because I got everything in 'received'
		; let's clean up all remaining '-1' in the 'received' array.
		FREE_LUN,lun
		ss= WHERE(received EQ NULLSTRING)
		received=received(0:ss(0)-1)		
		RETURN,received
END



