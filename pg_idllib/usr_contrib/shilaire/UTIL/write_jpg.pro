; PSH, May 4th 2001
;
; this routine writes a pseudo_color image to a .jpg file.
; color correspondence is not extraordinary, but it works...
;
; Modified (endlich!) on 2002/02/21 so that r,g,b are the current values, if not specified.
;							And if filename is not specified, then 'idl.jpg' is assumed.
;
;
;	EXAMPLES: 
;		1) write_jpg,'myfile.jpg',TVRD(),r,g,b
;		2) write_jpg,TVRD(),r,g,b
;		3) write_jpg,TVRD()
;		4) write_jpg,'myfile.jpg',TVRD()
;
;

PRO write_jpg,filename,img,r,g,b

	np=N_PARAMS()
	IF np EQ 1 then filename='idl.jpg'
	IF np LE 2 then TVLCT,r,g,b,/GET
	
	S=size(img)
	timg=bytarr(3,S[1],S[2])
	for i=0,S[1]-1 do for j=0,S[2]-1 do timg(0,i,j)=r(img(i,j))
	for i=0,S[1]-1 do for j=0,S[2]-1 do timg(1,i,j)=g(img(i,j))
	for i=0,S[1]-1 do for j=0,S[2]-1 do timg(2,i,j)=b(img(i,j))
	WRITE_JPEG,filename,timg,TRUE=1
END
