; by Pascal Saint-Hilaire, Feb, 25th,2001
; shilaire@astro.phys.ethz.ch OR psainth@hotmail.com

; PURPOSE : to calculate the correct atan, given x and y
;	 	i.e. it spans the whole [0,2*!PI[ range...

; OUTPUT in radians

; EXAMPLE : print,myarctan(-1000.,-10.)


function myarctan,x,y
 if x eq 0. then begin
		    if y ge 0. then result = !PI/2 else result = 3*!PI/2
		 end   else begin
		  	if x ge 0. then  result = atan(y/x)  else result= !PI + atan(y/x)
       			    end
return,result
end
