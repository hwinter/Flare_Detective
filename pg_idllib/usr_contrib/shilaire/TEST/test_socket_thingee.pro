; .r test_socket_thingee
;
; needs IDL 5.4 at least !!!
;===========================

host='hercules'
port='daytime'
text='blablabla'



;host='www.astro.phys.ethz.ch'
;host='helene.ethz.ch'
;host='hercules'

port=80


socket_err=0
SOCKET,lun1,host,port,/GET_LUN,err=socket_err
IF socket_err eq 0 THEN BEGIN
	print,'Socket - OK!'
	PRINTF,lun1,'get index.html'
	READF,lun1,text
	FREE_LUN,lun1
	print,text
ENDIF ELSE PRINT,'Socket not ok ! '
END
