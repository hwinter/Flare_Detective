
;PURPOSE :
;	plot an image using the HESSI color table.
;	negative values of the image are in shades of blue, positive in shades of red/yellow
;
; Written by PSH in 2 minutes, 2002/01/15


PRO plot_image_v2,img,_extra=_extra
	;hessi_ct,/QUICK
	themin=min(img,max=themax)
	drange=max([abs(themin),abs(themax)])
	plot_image,img,min=-drange,max=drange,_extra=_extra
END
