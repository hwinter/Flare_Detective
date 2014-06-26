;+
; NAME:
;      pg_cn_clmbcoll_diffsolve
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
;      "theory.tex". An escape term is added here!
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

PRO pg_cn_clmbcollescape_dsolve,startdist=startdist,ygrid=ygrid,ytherm=ytherm,niter=niter $
                            ,dt=dt,lastdist=lastdist,diagnostic=diagnostic,tauescape=tauescape $
                            ,xrange=xrange,compensate=compensate
   
N=n_elements(startdist)
dt=fcheck(dt,1.)
dx=ygrid[1]-ygrid[0]
xrange=fcheck(xrange,[1d-9,1d2])
tauescape=fcheck(tauescape,1.)
th=2.09d-7

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
;cdiff[0]=0.
cdiffplus=shift(cdiff,-1) 
cdiffminus=shift(cdiff,1) 

cdiffminus[0]=pg_clmbdiff_dimless(ygrid[0]-dx,ytherm)
;cdiffplus[0]=0.
cdiffplus[N-1]=pg_clmbdiff_dimless(ygrid[N-1]+dx,ytherm)

cconv=pg_clmbconv_dimless(ygrid,ytherm);convection coefficient
;cconv[0]=0.
cconvplus=shift(cconv,-1)
cconvminus=shift(cconv,1)

cconvminus[0]=pg_clmbconv_dimless(ygrid[0]-dx,ytherm)
;cconvplus[0]=0.
cconvplus[N-1]=pg_clmbconv_dimless(ygrid[N-1]+dx,ytherm)

;end Computation of the diffusion coefficients



;normalization factor introduced by the change of variable E-->y

norm1=10d^(-2d*ygrid)/(2d*alog(10d)^2d);diff second derivative
norm2=-10d^(-2d*ygrid)/(2d*alog(10d));diff first derivative
norm3=-10d^(-ygrid)/alog(10d);conv first derivative
norm5=10d^(0.5*ygrid)
;end normalization factor introduced by the change of variable E-->y

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


   ;stop

   gridplus=shift(grid,-1)
   gridminus=shift(grid,1)

   gridplus[N-1]=grid[N-1]+(grid[N-1]-grid[N-2]); does this make sense? --> better approach
   ;gridminus[0]=grid[0]/(egrid[0]/10^(ygrid[0]-dx))^(alog(grid[1]/grid[0])/alog(egrid[1]/egrid[0]))
   gridminus[0]=grid[0]-(grid[1]-grid[0]);/(egrid[0]/10^(ygrid[0]-dx))^(alog(grid[1]/grid[0])/alog(egrid[1]/egrid[0]))

;grid[0];    padding of the grid! try it!


   ;how to deal with boundary condition?
   ;IF grid[2] NE 0d THEN grid[0]=grid[1]*grid[1]/grid[2]

   ;gridminus[0]=grid[0]*grid[0]/grid[1]


;everything implicit crank-nicholson

   b=grid+ dtover2dxdx * norm1 $
         * (cdiffplus*gridplus - 2*cdiff*grid + cdiffminus*gridminus) $
         + dtover4dx * norm2 $
         * (cdiffplus*gridplus -cdiffminus*gridminus) $
         + dtover4dx * norm3 $
         * (cconvplus*gridplus -cconvminus*gridminus) $; $
         -dt*sqrt(2)*th*norm5*grid/tauescape

   diagonal= iden + dtover2dxdx * norm1 * 2*cdiff
                 
   superdiagonal= - dtover2dxdx * norm1 * cdiffplus $
                  - dtover4dx   * norm2 * cdiffplus $
                  - dtover4dx   * norm3 * cconvplus
                 
   subdiagonal=   - dtover2dxdx * norm1 * cdiffminus $
                  + dtover4dx   * norm2 * cdiffminus $
                  + dtover4dx   * norm3 * cconvminus
               

   newgrid=trisol(subdiagonal,diagonal,superdiagonal,b)

   grid=newgrid;-dt*sqrt(2d)*th*norm5*grid/tauescape

   ;grid=newgrid



 

   ;plots, if required
   IF i MOD 10d^(floor(alog10(i))-1) EQ 0 THEN BEGIN 



  ;implement diagnostic...!!
   ;
   ;

         this_diagnostic.iter=i
         this_diagnostic.grid=grid
         this_diagnostic.partnumber= $
                         total(0.5*(grid[0:N-2]+grid[1:N-1])*(egrid[1:N-1]-egrid[0:N-2]))
;total(grid);this is wrong, it should be integrated instead
         diagnostic=[diagnostic,this_diagnostic]

         IF keyword_set(compensate) THEN $
            grid=grid*1d10/this_diagnostic.partnumber ;!!!


                                ;expectation values of energy, number
                                ;of particles etc... as a function of time!


   
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
