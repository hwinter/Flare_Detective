; Created by PSH - 13 dec 2000
;takes two timestrings, t1 and t2,in almost any format (see str2utc 
;for more info), and returns the difference t1-t2 in seconds (float)

 
function psh_time_diff,t1,t2
a=str2utc(t1)
b=str2utc(t2)

return,(a.time-b.time)/1000.+(a.mjd-b.mjd)*86400.
	; I think 86400 is thew number that should be used...
end
