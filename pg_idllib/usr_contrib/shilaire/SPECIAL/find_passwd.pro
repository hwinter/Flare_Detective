;PSH 2001/12/22
;
;

server='hercules'
username='shilaire'
password='...'
passwordlist=['a','b','c','d','e',password]



;PRO find_passwd

socket_err=0
SOCKET,lun,/GET_LUN,server,23,err=socket_err,/rawio

IF socket_err eq 0 THEN BEGIN

	received='blabla'
	READU,lun,received
	print,received
	
	received='blabla'
	READU,lun,received
	print,received		
	
	sent=username
	WRITEU,lun,sent
			
	received='blabla'
	READU,lun,received
	print,received
	
	sent=password
	WRITEU,lun,sent
	
	;received='blabla'
	;READU,lun,received
	;print,received
	
	FREE_LUN,lun

ENDIF ELSE PRINT,'============= Socket not established ! ==============='
END


	
