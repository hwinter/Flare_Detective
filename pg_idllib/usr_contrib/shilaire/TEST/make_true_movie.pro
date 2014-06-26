; makes a true color movie of a trace_map and hxt_map
;
;PRO mytmp

;restore,'/global/tethys/HXR_DCIM/1999_09_08/19990809.dat',/verbose
;new_hxt_map=grid_map(hxt_map,dx=0.5,dy=0.5)

;-------------------------
xrange=[-790,-690]
yrange=[100,200]
Xdim=256
Ydim=256
i_start=50
i_end=80
moviepath='/global/helene/users/www/staff/shilaire/private/MOVIES/js_true5_19990908'
;-------------------------




files='frame'+int2str(i_start,4)+'.png'
for i=i_start+1,i_end do files=[files,'frame'+int2str(i,4)+'.png']

FOR i=i_start,i_end DO BEGIN
	print,i
	
	window,0,xsize=Xdim,ysize=Ydim
	;backgnd=64B+bytarr(Xdim,Ydim)
	;tv,backgnd,channel=2
	
	plot_map_true,trace_map(i),/noaxes,xmargin=[0,0],ymargin=[0,0], $
		xrange=xrange,yrange=yrange,trans=[8,0],/iso,channel=2	,top=128
	
	;plot_map_true,new_hxt_map,/noaxes,xmargin=[0,0],ymargin=[0,0], $
	;	xrange=xrange,yrange=yrange,/iso,channel=2,smooth=5	;,top=128	
	
	plot_map_true,trace_map(i),/noaxes,xmargin=[0,0],ymargin=[0,0], $
		xrange=xrange,yrange=yrange,trans=[8,0],/iso,channel=3,/NOERASE,/log
	
	plot_map_true,new_hxt_map,/noaxes,xmargin=[0,0],ymargin=[0,0], $
		xrange=xrange,yrange=yrange,/iso,channel=1,/NOERASE, $
		lcolor=!D.N_COLORS-1,smooth=5	;,grid=10

	theimage=TVRD(/TRUE)
	
	filename=moviepath+'/frame'+int2str(i,4)
	WRITE_PNG,filename+'.png',theimage
	;WRITE_JPEG,filename+'_25.jpg',theimage,/TRUE,QUALITY=25
	;WRITE_JPEG,filename+'_75.jpg',theimage,/TRUE,QUALITY=75
	;WRITE_JPEG,filename+'_100.jpg',theimage,/TRUE,QUALITY=100
ENDFOR

myjsmovie,moviepath+'/runme.html',files
END
