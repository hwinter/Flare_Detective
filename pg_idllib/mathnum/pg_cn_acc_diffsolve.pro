;+
; NAME:
;      pg_cn_acc_diffsolve
;
; PROJECT:
;      diffusion & acceleration (plasma physics)
;
; PURPOSE: 
;      based on the diffusion coefficients from interaction of
;      test electrons with maxwellian field electrons, implements
;      a numerical cracnk-nicholson scheme for the solution of the
;      advective-diffusive transport equation given by Miller (1996)
;      For details on the theory & deifference scheme, see
;      "theory.tex"
;      This also uses a systematic acceleration coefficient.
;
;      ++++++++++ NOTATION: y=log_10(e)
;                           e= energy in units of mc^2
;
;
; CALLING SEQUENCE:
;     
;
; INPUTS:
;      startdist: starting distribution of the test electrons
;      ygrid: y coordinates of the grid points
;      ytherm: thermal energy of the field plasma (in y units)
;      niter: maximum number of iterations to do (-1 means go on indefinitely)
;   
; OUTPUTS:
;      
;      
; KEYWORDS:
;
;
; HISTORY:
;       06-JUL-2005 written PG
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;
;-

PRO pg_cn_acc_diffsolve,startdist=startdist,ygrid=ygrid,ytherm=ytherm,niter=niter $
  ,dt=dt,lastdist=lastdist,diagnostic=diagnostic,w0=w0,xrange=xrange,ycutoff=ycutoff $
  ,tauescape=tauescape,compensate=compensate

doescape=exist(tauescape)

N=n_elements(startdist)
dt=fcheck(dt,1.)
dx=ygrid[1]-ygrid[0]
xrange=fcheck(xrange,[1d-9,1d2])

dtover2dxdx=dt/(2*dx*dx)
dtover4dx=dt/(4*dx)

iden=replicate(1.,N);N vector of ones

egrid=10d^ygrid ;grid energy
etherm=10^ytherm;field thermal energy

niter=fcheck(niter,1000000L)
niter=long(niter)
print,'Will compute  '+strtrim(string(niter),2)+' iterations'

linecolors

;Computation of the diffusion coefficients

cdiff=pg_clmbdiff_dimless(ygrid,ytherm);diffusion coefficient
cdiffplus=shift(cdiff,-1) 
cdiffminus=shift(cdiff,1) 

cdiffminus[0]=pg_clmbdiff_dimless(ygrid[0]-dx,ytherm)
cdiffplus[N-1]=pg_clmbdiff_dimless(ygrid[N-1]+dx,ytherm)

cconv=pg_clmbconv_dimless(ygrid,ytherm);convection coefficient
cconvplus=shift(cconv,-1)
cconvminus=shift(cconv,1)

cconvminus[0]=pg_clmbconv_dimless(ygrid[0]-dx,ytherm)
cconvplus[N-1]=pg_clmbconv_dimless(ygrid[N-1]+dx,ytherm)

accel=pg_accel_dimless(ygrid,w0=w0,ycutoff=ycutoff)
accelplus=shift(accel,-1)
accelminus=shift(accel,1)

;accelminus[0]=accel[0]-(accel[1]-accel[0]);pg_accel_dimless(ygrid[0]-dx,w0=w0,ycutoff=ycutoff)
;accelplus[N-1]=pg_accel_dimless(ygrid[N-1]+dx,w0=w0,ycutoff=ycutoff)
accelminus[0]=accel[0]-(accel[1]-accel[0]);pg_accel_dimless(ygrid[0]-dx,w0=w0,ycutoff=ycutoff)
accelplus[N-1]=accel[N-1]+(accel[N-1]-accel[N-2]);pg_accel_dimless(ygrid[N-1]+dx,w0=w0,ycutoff=ycutoff)
;stop

;end Computation of the diffusion coefficients

;stop

;normalization factor introduced by the change of variable E-->y

norm1=10d^(-2d*ygrid)/(2d*alog(10d)^2d);diff second derivative
norm2=-10d^(-2d*ygrid)/(2d*alog(10d));diff first derivative
norm3=-10d^(-ygrid)/alog(10d);conv first derivative
norm4=10d^(-ygrid)/(alog(10d)^2);acceleration second derivative
normescape=10d^(0.5*ygrid)
;end normalization factor introduced by the change of variable E-->y


th=2.09d-7

;stop
;plot,egrid,norm1*cdiff,/ylog,/xlog
;oplot,egrid,norm4*accel


;setup starting values
grid=double(startdist)
done=0
i=0.

partnumber=total(0.5*(grid[0:N-2]+grid[1:N-1])*(egrid[1:N-1]-egrid[0:N-2]))

;diagnostic structure
this_diagnostic={iter:0L, partnumber:partnumber, grid:grid}

diagnostic=this_diagnostic
;go with the numercial iterations

WHILE NOT done DO BEGIN

   IF i GT niter THEN BREAK 

   i=i+1


   gridplus=shift(grid,-1)
   gridminus=shift(grid,1)

   gridplus[N-1]=grid[N-1]; does this make sense? --> better approach
   gridminus[0]=grid[0];-(grid[1]-grid[0]);    padding of the grid! try it!


   ;how to deal with boundary condition?
   ;IF grid[2] NE 0d THEN grid[0]=grid[1]*grid[1]/grid[2]

   ;gridminus[0]=grid[0]*grid[0]/grid[1]


;everything implicit crank-nicholson

   b=grid+ dtover2dxdx * norm1 $
         * (cdiffplus*gridplus - 2*cdiff*grid + cdiffminus*gridminus) $
         + dtover4dx * norm2 $
         * (cdiffplus*gridplus -cdiffminus*gridminus) $
         + dtover4dx * norm3 $
         * (cconvplus*gridplus -cconvminus*gridminus) $
         + dtover2dxdx * norm4 $
         * (accelplus*gridplus - 2*accel*grid + accelminus*gridminus)




  ; stop

   
   diagonal= iden + dtover2dxdx * norm1 * 2*cdiff $
                  + dtover2dxdx * norm4 * 2*accel
                 
   superdiagonal= - dtover2dxdx * norm1 * cdiffplus $
                  - dtover4dx   * norm2 * cdiffplus $
                  - dtover4dx   * norm3 * cconvplus $
                  - dtover2dxdx * norm4 * accelplus

   subdiagonal=   - dtover2dxdx * norm1 * cdiffminus $
                  + dtover4dx   * norm2 * cdiffminus $
                  + dtover4dx   * norm3 * cconvminus $
                  - dtover2dxdx * norm4 * accelminus

   newgrid=trisol(subdiagonal,diagonal,superdiagonal,b)


   ;stop

   IF doescape THEN BEGIN
       newgrid=grid-dt*th*(1/tauescape)*sqrt(2.)*normescape*grid
       ;print,max(b2/b),min(b2/b)
   ENDIF

   grid=newgrid


   ;implement diagnostic...!!
   ;
   ;

;   IF i GT 1000 THEN 


                                ;expectation values of energy, number
                                ;of particles etc... as a function of time!


   ;plots, if required
   IF i MOD 10d^(floor(alog10(i))-1) EQ 0 THEN BEGIN 



         this_diagnostic.iter=i
         this_diagnostic.grid=grid
         this_diagnostic.partnumber= $
                         total(0.5*(grid[0:N-2]+grid[1:N-1])*(egrid[1:N-1]-egrid[0:N-2]))
;total(grid);this is wrong, it should be integrated instead
         diagnostic=[diagnostic,this_diagnostic]



      IF keyword_set(compensate) THEN $
        grid=grid*1d10/this_diagnostic.partnumber


   
 ;  plot,e,alog(10)*e*abs(grid),/xlog,/ylog,yrange=[1d0,1d15],xrange=[1d-7,1d-1] $
  ;     ,psym=1,title='time '+strtrim(string(i),2)
  ; oplot,10^ytherm*[1,1],10^!Y.crange,linestyle=1
   plot,egrid,abs(grid),/xlog,/ylog,yrange=[1d-5,1d15],xrange=xrange $
       ,psym=-6,title='time '+strtrim(string(i),2)
   oplot,10^ytherm*[1,1],10^!Y.crange,linestyle=1

   oplot,egrid,1d10*pg_maxwellian(egrid,etherm),color=12,thick=1
;,/ylog,/xlog,xrange=[1d-7,1d-1],yrange=[1d0,1d15]
;oplot,10^ytherm*[1,1],10^!Y.crange,linestyle=1




   wait,0.1
   ENDIF


ENDWHILE


lastdist=grid

END
