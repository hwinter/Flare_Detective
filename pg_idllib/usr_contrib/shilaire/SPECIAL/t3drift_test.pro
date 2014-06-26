;GOTO,PROCHAIN

;============================
;;;EXPLORING THE PHASE SPACE:

x=4*FINDGEN(100)/100.-1.95
y=x
dir=FINDGEN(36)*10.
beta=FINDGEN(99)/100.+0.01

n_x=N_ELEMENTS(x)
n_y=N_ELEMENTS(y)
n_dir=N_ELEMENTS(dir)
n_beta=N_ELEMENTS(beta)
n_tot=n_x*n_y*n_dir*n_beta
res=FLTARR(n_x,n_y,n_dir,n_beta)

FOR i=0,n_x-1 DO BEGIN	&$
	FOR j=0,n_y-1 DO BEGIN	&$
		FOR k=0,n_dir-1 DO BEGIN	&$
			FOR l=0,n_beta-1 DO BEGIN	&$
				nu_dot_over_nu=-1		&$
				t3drift,[x[i],y[j]], beta[l], dir[k],nu_dot_over_nu=nu_dot_over_nu,/SILENT	&$
				res[i,j,k,l]=nu_dot_over_nu	&$
			ENDFOR					&$
		ENDFOR						&$
	ENDFOR							&$
	PRINT,'Percent done: '+strn(100.*(i+1)/n_x)			&$
ENDFOR
PRINT,MAX(res)

PROCHAIN:
;------------------------------------------------------------------------------
;NOW, visualize where the drift rate can be bigger than +1.5 s^-1.
img=res[*,*,0,0]
FOR i=0,n_x-1 DO BEGIN
	FOR j=0,n_y-1 DO BEGIN
		img[i,j]=MAX(res[i,j,*,*])
	ENDFOR
ENDFOR
plot_image,img-1.5,/VEL,min=1.5,max=1.5
tvellipse,25,25,50.5,50.5,/DATA,color=1
;anything above black (red,yellow, white) may have a drift rate bigger than +1.5...
END






