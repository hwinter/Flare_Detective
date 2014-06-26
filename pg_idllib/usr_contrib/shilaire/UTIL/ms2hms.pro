;+
; created by Pascal Saint-Hilaire on dec 1st,2000
;	shilaire@astro.phys.ethz.ch OR psainth@hotmail.com
; returns a string under the format HH:MM:SS.xxx, from an input in milliseconds
; optional keywords: 	
;		/nocolon : if you don't want ':' between numbers
;		/noms  : if you don't want to have millisecs
; RESTRICTIONS : does not work very well if in_ms is longer than a LONG...
; MODIFICATIONS:
;		PSH, 2001/08/06 : modified to accepts arrays of numbers
;-



FUNCTION avec_zero_svp,nbr
	ss1=where(nbr lt 10)
	ss2=where(nbr ge 10)	
	tmp=STRING(nbr)
	if ss1(0) ne -1 then tmp(ss1)='0'+StrTrim(nbr(ss1),1)
	if ss2(0) ne -1 then tmp(ss2)=StrTrim(nbr(ss2),1)
	return,tmp
END

function ms2hms,in_ms,nocolon=nocolon,noms=noms
	ms=in_ms
	cur=LONG(ms/3600000)
	str=avec_zero_svp(cur)
	if not exist(nocolon) then str=str+':'
	ms=ms-3600000*cur
	cur=LONG(ms/60000)
	str=str+avec_zero_svp(cur)
	if not exist(nocolon) then str=str+':'
	ms=ms-60000*cur
	cur=LONG(ms/1000)
	str=str+avec_zero_svp(cur)
	ms=ms-1000*cur
	cur=LONG(ms)
	if not exist(noms) then begin
		str=str+'.'
		ss=where(cur lt 100)
		if ss(0) ne -1 then str(ss)=str(ss)+'0'
		str=str+avec_zero_svp(cur)
	endif
return,str
end
