;+
; NAME:
;      pg_cn_millerfix
;
; PROJECT:
;      diffusion & acceleration (plasma physics)
;
; PURPOSE: 
;      based on the diffusion coefficients from interaction of
;      test electrons with maxwellian field electrons, implements
;      a numerical cracnk-nicholson scheme for the solution of the
;      advective-diffusive transport equation given by Miller (1996)
;      The systematic acceleration coefficients by Miller A(E) and D(E)
;      are used but the turbulence energy density and the average
;      k (that is <k>) are held constant in time!
;      For details on the theory & deifference scheme, see
;      "theory.tex"
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
;       15-JUL-2005 added the (fixed) D and A coefficients + escape
;       18-JUL-2005 relativistic escape (?)
;       19-JUL-2005 added maxwellian source
;       28-JUl-2005 implemented mechanism for variation of the escape term
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;
;-

PRO pg_cn_millerfix_varescape,startdist=startdist,ygrid=ygrid,ytherm=ytherm,niter=niter $
                   ,dt=dt,lastdist=lastdist,diagnostic=diagnostic,xrange=xrange $
                   ,accfactor=accfactor,yrange=yrange,tauescape=tauescape $
                   ,compensate=compensate,maxwsrctemp=maxwsrctemp $
                   ,avckomega=avckomega,utdivbyub=utdivbyub,noplot=noplot $
                   ,escapefun=escapefun,_extra=_extra


N=n_elements(startdist)
dt=fcheck(dt,1.)
dx=ygrid[1]-ygrid[0]
xrange=fcheck(xrange,[1d-9,1d2])
yrange=fcheck(yrange,[1d-5,1d15])
accfactor=fcheck(accfactor,1d)

th=2.09d-7

IF keyword_set(tauescape) THEN doescape=1 ELSE doescape=0

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

;diffusion coefficient
cdiff=pg_clmbdiff_dimless(ygrid,ytherm) +$
      pg_miller_dcoeff_dimless(ygrid,avckomega=avckomega,utdivbyub=utdivbyub) 

;cdiff[0]=0.
cdiffplus=shift(cdiff,-1) 
cdiffminus=shift(cdiff,1) 

cdiffminus[0]=pg_clmbdiff_dimless(ygrid[0]-dx,ytherm) +$
              pg_miller_dcoeff_dimless(ygrid[0]-dx,avckomega=avckomega,utdivbyub=utdivbyub)
;cdiffplus[0]=0.
cdiffplus[N-1]=pg_clmbdiff_dimless(ygrid[N-1]+dx,ytherm)+$
               pg_miller_dcoeff_dimless(ygrid[N-1]+dx,avckomega=avckomega,utdivbyub=utdivbyub)

;convection coefficient
cconv=pg_clmbconv_dimless(ygrid,ytherm) +$
      pg_miller_acoeff_dimless(ygrid,avckomega=avckomega,utdivbyub=utdivbyub) 

;cconv[0]=0.
cconvplus=shift(cconv,-1)
cconvminus=shift(cconv,1)

cconvminus[0]=pg_clmbconv_dimless(ygrid[0]-dx,ytherm)+accfactor*pg_miller_acoeff_dimless(ygrid[0]-dx)
;cconvplus[0]=0.
cconvplus[N-1]=pg_clmbconv_dimless(ygrid[N-1]+dx,ytherm)+accfactor*pg_miller_acoeff_dimless(ygrid[N-1]+dx)

;end Computation of the diffusion coefficients



;normalization factor introduced by the change of variable E-->y

norm1=10d^(-2d*ygrid)/(2d*alog(10d)^2d);diff second derivative
norm2=-10d^(-2d*ygrid)/(2d*alog(10d));diff first derivative
norm3=-10d^(-ygrid)/alog(10d);conv first derivative

normescape=10d^(0.5*ygrid)

;end normalization factor introduced by the change of variable E-->y

;setup starting values
grid=double(startdist)
done=0
i=0.
tottemp=0d

partnumber=total(0.5*(grid[0:N-2]+grid[1:N-1])*(egrid[1:N-1]-egrid[0:N-2]))

;diagnostic structure
this_diagnostic={iter:0L, partnumber:partnumber, grid:grid, tottemp:tottemp}

diagnostic=this_diagnostic
;go with the numercial iterations

WHILE NOT done DO BEGIN

   IF i GT niter THEN BREAK 

   i=i+1

   tottemp=tottemp+dt

   ;stop

   gridplus=shift(grid,-1)
   gridminus=shift(grid,1)

   gridplus[N-1]=grid[N-1]; does this make sense? --> better approach
   ;gridminus[0]=grid[0]/(egrid[0]/10^(ygrid[0]-dx))^(alog(grid[1]/grid[0])/alog(egrid[1]/egrid[0]))
   gridminus[0]=grid[0];/(egrid[0]/10^(ygrid[0]-dx))^(alog(grid[1]/grid[0])/alog(egrid[1]/egrid[0]))

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
         * (cconvplus*gridplus -cconvminus*gridminus)
   
   diagonal= iden + dtover2dxdx * norm1 * 2*cdiff
                 
   superdiagonal= - dtover2dxdx * norm1 * cdiffplus $
                  - dtover4dx   * norm2 * cdiffplus $
                  - dtover4dx   * norm3 * cconvplus
                 
   subdiagonal=   - dtover2dxdx * norm1 * cdiffminus $
                  + dtover4dx   * norm2 * cdiffminus $
                  + dtover4dx   * norm3 * cconvminus
               

   newgrid=trisol(subdiagonal,diagonal,superdiagonal,b)

   ;add escape term

   IF doescape THEN BEGIN 

      dgridescape=call_function(escapefun,egrid=egrid,grid=grid,tauescape=tauescape $ 
                               ,dt=dt,th=th,_extra=_extra)

      ;escape --> either relativistic
      ;formula or non relativistic (see theory.tex)

;      IF keyword_set(relescape) THEN BEGIN
         ;this is the relativistic version
;         gamma=1+egrid
;         vv=sqrt(1-1/(gamma*gamma))
;         dgridescape=dt*th*(1/tauescape)*vv*grid
;         grid=newgrid-dgridescape
;      ENDIF $
;      ELSE BEGIN
;         ;non relativistci version
;         dgridescape=dt*th*(1/tauescape)*sqrt(2.)*normescape*grid
      grid=newgrid-dgridescape
   ;ENDIF 

      ;stop
      
      ;add a maxwellian source if required
      ;please do not use this in conjunction with the compensate keyword
      IF exist(maxwsrctemp) THEN BEGIN
         escapedpartnumber=total(0.5*(dgridescape[0:N-2]+dgridescape[1:N-1])*(egrid[1:N-1]-egrid[0:N-2]))
         q=escapedpartnumber*pg_maxwellian(egrid,10d^maxwsrctemp)
         grid=grid+q
      ENDIF

   ENDIF $
   ELSE grid=newgrid


   ;plots, if required
   IF i MOD 10d^(floor(alog10(i))-1) EQ 0 THEN BEGIN 


      print,'Iter # '+strtrim(string(i),2)

      ;implement diagnostic

      this_diagnostic.iter=i
      this_diagnostic.grid=grid
      this_diagnostic.partnumber= $
           total(0.5*(grid[0:N-2]+grid[1:N-1])*(egrid[1:N-1]-egrid[0:N-2]))
           ;total(grid);this is wrong, it should be integrated instead
      this_diagnostic.tottemp=tottemp
      diagnostic=[diagnostic,this_diagnostic]


      ;expectation values of energy, number
      ;of particles etc... as a function of time!

      
      IF keyword_set(compensate) THEN BEGIN
         grid=grid*1d10/this_diagnostic.partnumber ;/1d10
      ENDIF

      IF keyword_set(relescape) THEN print,'relescape!!'


      IF NOT keyword_set(noplot) THEN BEGIN 
         plot,egrid,abs(grid),/xlog,/ylog,yrange=yrange,xrange=xrange $
              ,psym=-6,title='time '+strtrim(string(i),2)
         oplot,10^ytherm*[1,1],10^!Y.crange,linestyle=1
         oplot,egrid,1d10*pg_maxwellian(egrid,etherm),color=12,thick=1

         wait,0.1

      ENDIF

   ENDIF

ENDWHILE

lastdist=grid

END
