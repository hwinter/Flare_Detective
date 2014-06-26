
PRO url_copy

	host='vestige.lmsal.com'
	cmd='/cgi-bin/disp_fits.pl?/var/www/htdocs/TRACE/image_client/tri20021201.0000_0251.fits'
	out_file='test.test'
	
	buff_size=10L	;1MB ....
	
	SOCKET,ilun,/GET_LUN,host,80
	;PRINTF,ilun,'GET '+cmd+'HTTP/1.0'+STRING(10B)+STRING(10B)
	PRINTF,ilun,cmd
	OPENW,olun,out_file,/GET_LUN
	
	data=BYTARR(buff_size,/NOZERO)
	READU,ilun,data
	WRITEU,olun,data
	
	CLOSE,/ALL
END
