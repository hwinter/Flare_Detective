
TkeV=1.1
EM49=0.14
npts=100
charsize=1.2

E=DINDGEN(npts)/(npts/100.)
E1=E+2d2/npts
E2=TRANSPOSE([[E],[E+1d2/npts]])

th=f_vth(E2,[EM49,TkeV])
PLOT,E1,th,/XLOG,/YLOG,xr=[3,100],xstyle=1,yr=[0.1,1d5],xtit='h!7m!3 [keV]',charsize=charsize,ytit='Flux [photons s!U-1!N cm!U-2!N keV!U-1!N]'


