;+
;NAME:
; 	int2str.pro
;PROJECT:
; 	ETHZ Radio Astronomy
;CATEGORY:
; 	gen
;PURPOSE:
; This routine will return a string representation of an interger. This
; string has a length 'len'. Empty spaces on the left are filled up with 
; zeros. Very useful for filenaming.
;
;CALLING SEQUENCE:
;	res=int2str(nbr,length)
;
;INPUT:
;	nbr    : an integer
;	len	  : an integer
;
;OUTPUT:
;	a string representation of 'nbr', of length 'len'
;
;EXAMPLES:
;	IDL> text=int2str(123,5)
;	IDL> print,text
;	00123
;
;	IDL> for i=0,N_ELEMENTS(imgarr(0,0,*))-1 DO WRITE_GIF,'Img_'+int2str(i,4)+'.gif',imgarr(*,*,i),r,g,b
;
;HISTORY:
;
;	2001/02/24 created. Pascal Saint-Hilaire [shilaire@astro.phys.ethz.ch]
;	
;	2002/05/03 modified, PSH: returns the least significant portion of the number passed,
;								if it size is larger than 'len'.
;
;-

function int2str,value,length
	bla=STRTRIM(value,2)
	IF STRLEN(bla) GT length THEN bla=STRMID(bla,length-1,length,/REVERSE_OFFSET) ELSE BEGIN
		WHILE STRLEN(bla) LT length DO bla='0'+bla
	ENDELSE
	return, bla
end
