; PSH , 2001/05/02

PRO oplot_error_bars, x,y, deltax, deltay, notips=notips,color=color,tipsize=tipsize,_extra=_extra

if not exist(color) then color=!D.N_colors-1
if not exist(tipsize) then tipsize=(deltax < deltay)/3.

oplot,[x-deltax,x+deltax],[y,y],color=color,_extra=_extra
oplot,[x,x],[y-deltay,y+deltay],color=color,_extra=_extra

data_per_normal=convert_coord([1.,0],/data,/to_normal)
data_per_normal=data_per_normal(0)

if not exist(notips) then BEGIN
		oplot,[x-deltax,x-deltax],[y-tipsize,y+tipsize+data_per_normal],color=color,_extra=_extra
		oplot,[x+deltax,x+deltax],[y-tipsize,y+tipsize+data_per_normal],color=color,_extra=_extra
		oplot,[x-tipsize,x+tipsize+data_per_normal],[y-deltay,y-deltay],color=color,_extra=_extra
		oplot,[x-tipsize,x+tipsize+data_per_normal],[y+deltay,y+deltay],color=color,_extra=_extra		
			  END
END
