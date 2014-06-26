GOTO,PROCHAIN

;============================
;;;EXPLORING THE PHASE SPACE:

x=4*FINDGEN(100)/100.-1.95
y=x
dir=FINDGEN(36)*10.

n_x=N_ELEMENTS(x)
n_y=N_ELEMENTS(y)
n_dir=N_ELEMENTS(dir)
n_tot=n_x*n_y*n_dir
res=FLTARR(n_x,n_y,n_dir)

FOR i=0,n_x-1 DO BEGIN	&$
	FOR j=0,n_y-1 DO BEGIN	&$
		FOR k=0,n_dir-1 DO BEGIN	&$
			nu_dot_over_nu=-1		&$
			extended_source_drift,[x[i],y[j]], dir[k],nu_dot_over_nu=nu_dot_over_nu,/SILENT	&$
			res[i,j,k]=nu_dot_over_nu	&$
		ENDFOR						&$
	ENDFOR							&$
	PRINT,'Percent done: '+strn(100.*(i+1)/n_x)			&$
ENDFOR
PRINT,MAX(res)

hessi_ct	;,/BW
PROCHAIN:
;------------------------------------------------------------------------------
;NOW, visualize where the drift rate is positive.
img=res[*,*,0]
FOR i=0,n_x-1 DO BEGIN
	FOR j=0,n_y-1 DO BEGIN
		img[i,j]=MAX(res[i,j,*])
	ENDFOR
ENDFOR
plot_image,img-1.5,/VEL
tvellipse,25,25,50.5,50.5,/DATA,color=1
END






