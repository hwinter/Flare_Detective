;PURPOSE:
;	This routine inverses the black and the white in the color tables...
;
;



PRO bw_inverse, filename=filename

	maxindex=!D.TABLE_SIZE-1
	minindex=0
	
	IF KEYWORD_SET(filename) THEN READ_PNG,filename,img,r,g,b ELSE TVLCT,r,g,b,/GET	
	IF datatype(r) EQ 'UND' THEN TVLCT,r,g,b,/GET
	
	rmin=r[minindex] & gmin=g[minindex] & bmin=b[minindex] 
	r[minindex]=r[maxindex] & g[minindex]=g[maxindex] & b[minindex]=b[maxindex]
	r[maxindex]=rmin & g[maxindex]=gmin & b[maxindex]=bmin	
	TVLCT,r,g,b

	IF KEYWORD_SET(filename) THEN WRITE_PNG,filename,img,r,g,b ELSE TVLCT,r,g,b
END
