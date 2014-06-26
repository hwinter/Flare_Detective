; fills image with gaussians
; [offset,amplitude,xc,yc,a,b,theta]
;
; EXAMPLES:
;	img=image_with_gaussians([0,1,64,64,10,10,0])
;	img=image_with_gaussians([[0,1,64,64,10,10,0],[0,0.5,10,64,50,10,-45]])
;	plot_image,img
;
;Testing NRH routine extract_sources.pro:
;	n_src_max=1
;	src=REPLICATE({gra:-1d,grb:-1d,tet:0d,max:-1d,xmax:0d,ymax:0d},n_src_max)
;	img=image_with_gaussians([0,1,64,64,10,10,0])
;	extract_sources,img,src, NBMAX=n_src_max,fmax=0.5
;	ss=WHERE(src.gra GE 0) & IF ss[0] NE -1 THEN src=src[ss]
;	src.gra=1/sqrt(src.gra) & src.grb=1/sqrt(src.grb)
;	PRINT,src.gra	;those are actually the HWHM, not the semi-major/minor axes!
;	PRINT,src.grb
;	
;

FUNCTION image_with_gaussians, params, imgsize=imgsize
	IF NOT KEYWORD_SET(imgsize) THEN imgsize=128
	par=FLOAT(params)
	img=FLTARR(imgsize,imgsize)
	ngauss=N_ELEMENTS(params[0,*])
	
	FOR i=0L,imgsize-1 DO BEGIN
		FOR j=0,imgsize-1 DO BEGIN
			FOR k=0,ngauss-1 DO BEGIN
				img[i,j]=img[i,j]+par[0,k]+par[1,k]*exp(-0.5 *( (  ((i-par[2,k])*cos(180.*par[6,k]/!PI) - (j-par[3,k])*sin(180.*par[6,k]/!PI) )/par[4,k])^2 +  (  ((j-par[3,k])*cos(180.*par[6,k]/!PI) + (i-par[2,k])*sin(180.*par[6,k]/!PI))/par[5,k])^2))
			ENDFOR				
		ENDFOR		
	ENDFOR
	RETURN,img
END
