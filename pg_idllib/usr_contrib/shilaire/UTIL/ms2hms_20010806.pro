; created by Pascal Saint-Hilaire on dec 1st,2000

; returns a string under the format HH:MM:SS.xxx, from an input in milliseconds
; optional keywords: 	
;		/nocolon : if you don't want ':' between numbers
;		/noms  : if you don't want to have millisecs
; RESTRICTIONS : does not work very well if in_ms is longer than a LONG...

FUNCTION avec_zero_svp,nbr
if nbr lt 10 then return,'0'+StrTrim(nbr,1) else return, StrTrim(nbr,1)
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
			if cur lt 100 then str=str+'0'
			str=str+avec_zero_svp(cur)
			end

;str=str+string(cur,format='(".",I2)')   old version...

return,str
end
