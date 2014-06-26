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
;      niter: maximum number of iterations to do (-1 means go on
;             indefinitely)
;      density: density of the starting distribution. This is also
;               the density of the field particles throughout the simulation
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
;       30-SEP-2005 added some fields to the output diagnostic
;                   structure
;       03-OCT-2005 uses simpar as input/output parameter interface
;       21-NOV-2005 added density parameter after changing collision
;                   term functions (& acceleration!)
;       28-NOV-2005 escape term modifications (lower threshold)
;       31-JAN-2006 added tauescape array input, for tauescape energy dependent
;       09-MAR-2006 save_memory keyword added
;       22-MAR-2006 allsave keyword added
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;       pgrigis@astro.phys.ethz.ch
;
;-

PRO pg_cn_millerfix,startdist=startdist,ygrid=ygrid,ytherm=ytherm,niter=niter $
                   ,dt=dt,lastdist=lastdist,diagnostic=total_diagnostic,xrange=xrange $
                   ,accfactor=accfactor,yrange=yrange,tauescape=tauescape $
                   ,compensate=compensate,relescape=relescape,maxwsrctemp=maxwsrctemp $
                   ,avckomega=avckomega,utdivbyub=utdivbyub,noplot=noplot $
                   ,simpar=simpar,quiet=quiet,nsum=nsum,waitpar=waitpar $
                   ,density=density,debug=debug,clmblog=clmblog $
                   ,threshold_escape_kev=threshold_escape_kev $
                   ,collision_strength_scale=collision_strength_scale $
                   ,array_tauescape=array_tauescape $
                   ,dimless_time_unit=dimless_time_unit $
                   ,save_memory=save_memory,allsave=allsave

IF exist(array_tauescape) THEN BEGIN 
   docustomescape=1 
   IF n_elements(array_tauescape) NE n_elements(ygrid) THEN BEGIN 
      print,'INVALID TAUESCAPE ARRAY INPUT'
      RETURN
   ENDIF
ENDIF ELSE docustomescape=0

IF keyword_set(save_memory) THEN BEGIN 
   ind_save=0L
ENDIF


dodebug=keyword_set(debug)
startime=systime(1)

relescape=1;ignores relescape=0

waitpar=fcheck(waitpar,0.1)

nsum=fcheck(nsum,1)
N=n_elements(startdist)
dt=fcheck(dt,1.)
dx=ygrid[1]-ygrid[0]
xrange=fcheck(xrange,[1d-9,1d2])
yrange=fcheck(yrange,[1d-5,1d15])
accfactor=fcheck(accfactor,1d)
clmblog=fcheck(clmblog,18d)
collision_strength_scale=fcheck(collision_strength_scale,1d)

th=fcheck(dimless_time_unit,2.09d-7)

mc2   = 510.998918d ;rest mass of the electron, in keV

IF keyword_set(tauescape) THEN doescape=1 ELSE doescape=0
IF exist(threshold_escape_kev) THEN $
   threshold_escape_mc2=threshold_escape_kev/mc2 ELSE BEGIN 
   threshold_escape_mc2=0.
   threshold_escape_kev=0.
ENDELSE


dtover2dxdx=dt/(2*dx*dx)
dtover4dx=dt/(4*dx)

iden=replicate(1.,N);N vector of ones

egrid=10d^ygrid ;grid energy
etherm=10^ytherm;field thermal energy

indescape=where(egrid GE threshold_escape_mc2,count_indescape)
IF count_indescape EQ 0 THEN BEGIN 
   print,'The escape energy lower threshold is so high'
   print,'that the model is equivalent to one without escape!'
   doescape=0
ENDIF

IF (NOT docustomescape) AND doescape THEN array_tauescape=replicate(tauescape,n_elements(egrid))


niter=fcheck(niter,1000000L)
niter=long(niter)
IF NOT keyword_set(quiet) THEN $
print,'Will compute  '+strtrim(string(niter),2)+' iterations'

linecolors

densmaxw=fcheck(density,1d10)


;first plot
      IF NOT keyword_set(noplot) THEN BEGIN 
         plot,egrid,abs(startdist),/xlog,/ylog,yrange=yrange,xrange=xrange $
              ,psym=-6,title='time '+strtrim(string(0),2),nsum=nsum
         oplot,egrid,-startdist,color=2,psym=6

         oplot,10^ytherm*[1,1],10^!Y.crange,linestyle=1
         oplot,egrid,densmaxw*pg_maxwellian(egrid,etherm),color=12,thick=1,nsum=nsum

         wait,waitpar

      ENDIF



;Computation of the diffusion coefficients

;diffusion coefficient
cdiff=pg_clmbdiff_dimless(ygrid,ytherm,density=densmaxw,clmblog=clmblog $
                         ,scale_factor=collision_strength_scale) +$
      accfactor*pg_miller_dcoeff_dimless(ygrid,avckomega=avckomega $
                                        ,utdivbyub=utdivbyub,eldensity=densmaxw) 


;test --> coeff equal 0 at low energies
;cdiff[0]=0.



cdiffplus=shift(cdiff,-1) 
cdiffminus=shift(cdiff,1) 

;test --> uncomment them to undo test, comment to activate
cdiffminus[0]=pg_clmbdiff_dimless(ygrid[0]-dx,ytherm,density=densmaxw,clmblog=clmblog $
                         ,scale_factor=collision_strength_scale) +$
              accfactor*pg_miller_dcoeff_dimless(ygrid[0]-dx,avckomega=avckomega, $
                                                 utdivbyub=utdivbyub,eldensity=densmaxw)
cdiffplus[N-1]=pg_clmbdiff_dimless(ygrid[N-1]+dx,ytherm,density=densmaxw,clmblog=clmblog $
                         ,scale_factor=collision_strength_scale)+$
               accfactor*pg_miller_dcoeff_dimless(ygrid[N-1]+dx,avckomega=avckomega, $
                                                  utdivbyub=utdivbyub,eldensity=densmaxw)

;convection coefficient
cconv=pg_clmbconv_dimless(ygrid,ytherm,density=densmaxw,clmblog=clmblog $
                         ,scale_factor=collision_strength_scale) +$
      accfactor*pg_miller_acoeff_dimless(ygrid,avckomega=avckomega,utdivbyub=utdivbyub,eldensity=densmaxw) 

;test --> coeff equal 0 at low energies
;cconv[0]=0.


cconvplus=shift(cconv,-1)
cconvminus=shift(cconv,1)

;test --> uncomment them to undo test, comment to activate
cconvminus[0]=pg_clmbconv_dimless(ygrid[0]-dx,ytherm,density=densmaxw,clmblog=clmblog $
                         ,scale_factor=collision_strength_scale)+ $
              accfactor*pg_miller_acoeff_dimless(ygrid[0]-dx,avckomega=avckomega $
                                                ,utdivbyub=utdivbyub,eldensity=densmaxw)
cconvplus[N-1]=pg_clmbconv_dimless(ygrid[N-1]+dx,ytherm,density=densmaxw,clmblog=clmblog $
                         ,scale_factor=collision_strength_scale)+ $
              accfactor*pg_miller_acoeff_dimless(ygrid[N-1]+dx,avckomega=avckomega $
                                                ,utdivbyub=utdivbyub,eldensity=densmaxw)

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
i=0L
tottemp=0d

partnumber=int_tabulated(ygrid,10^(ygrid)*grid,/double)*alog(10.)
           ;total(0.5*(grid[0:N-2]+grid[1:N-1])*(egrid[1:N-1]-egrid[0:N-2]))

;diagnostic structure
this_diagnostic={iter:0L, partnumber:partnumber, grid:grid, tottemp:tottemp};total time
                ;, energy:egrid $
                ;,etherm:etherm,ytherm:ytherm }


diagnostic=this_diagnostic


;stop

;go with the numercial iterations

WHILE NOT done DO BEGIN

   IF i GE niter THEN BREAK 

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
               

   newgrid=trisol(subdiagonal,diagonal,superdiagonal,b)>1d-300

   ;test!!!
   ;newgrid[0]=newgrid[1]

   ;add escape term

   IF doescape THEN BEGIN 

      ;escape --> either relativistic
      ;formula or non relativistic (see theory.tex)


;      IF keyword_set(relescape) THEN BEGIN

         ;this is the relativistic version
         gamma=1+egrid
         vv=sqrt(1-1/(gamma*gamma))
         dgridescape=newgrid*0.
         dgridescape[indescape]=dt*th/array_tauescape[indescape]*vv[indescape]*newgrid[indescape]

         grid=(newgrid-dgridescape);>1d-300
         IF dodebug THEN BEGIN 
            dummy=where(grid LT 0d,count)
            IF count GT 0 THEN BEGIN
               print,'Negative found at '+string(i)
            ENDIF
         ENDIF
         ;stop
;      ENDIF $
;      ELSE BEGIN
         ;non relativistic version

         ;not available anymore because of escape term changes PG 31-JAN-2005

         ;;threshold not implemented for non relativistic version
         ;dgridescape=dt*th*(1/tauescape)*sqrt(2.)*normescape*grid
         ;grid=(newgrid-dgridescape)>1d-300
;      ENDELSE

      ;stop
      
      ;add a maxwellian source if required
      ;please do not use this in conjunction with the compensate keyword
      IF exist(maxwsrctemp) THEN BEGIN
         escapedpartnumber=int_tabulated(ygrid,10^(ygrid)*dgridescape,/double)*alog(10.)
                           ;old method! --> less accurate
                           ;total(0.5*(dgridescape[0:N-2]+dgridescape[1:N-1])*(egrid[1:N-1]-egrid[0:N-2]))
         q=escapedpartnumber*pg_maxwellian(egrid,10d^maxwsrctemp)
         grid=grid+q
      ENDIF

   ENDIF $
   ELSE grid=newgrid


   IF keyword_set(compensate) THEN BEGIN
      ;print,'compensate'
      partnumber=int_tabulated(ygrid,10^(ygrid)*grid,/double)*alog(10.)
      grid=grid*densmaxw/partnumber 
   ENDIF



   ;plots, if required

;old system
;   IF i MOD 10d^(floor(alog10(i))-1) EQ 0 THEN BEGIN 

;new system --> one gets 0,1,2..9,10,20,30..100,200..1000,2000...
    modbas=round(10d^(floor(alog10(i))-1))>1

    IF keyword_set(allsave) THEN BEGIN 

       IF NOT keyword_set(quiet) THEN print,'Iter # '+strtrim(string(i),2)
       
       this_diagnostic.iter=i
       this_diagnostic.grid=grid
       this_diagnostic.partnumber=int_tabulated(ygrid,10^(ygrid)*grid,/double)*alog(10.)
       this_diagnostic.tottemp=tottemp

       diagnostic=[diagnostic,this_diagnostic]
       
       ;do plots if needed
       IF NOT keyword_set(noplot) THEN BEGIN 
          plot,egrid,abs(grid),/xlog,/ylog,yrange=yrange,xrange=xrange $
              ,psym=-6,title='time '+strtrim(string(i),2),nsum=nsum
          oplot,egrid,-grid,color=2,psym=6

          oplot,10^ytherm*[1,1],10^!Y.crange,linestyle=1
          oplot,egrid,densmaxw*pg_maxwellian(egrid,etherm),color=12,thick=1,nsum=nsum
                
          IF keyword_set(doescape) THEN oplot,egrid,dgridescape,color=10
                
          wait,waitpar
       ENDIF;plots


    ENDIF $;all save diagnostic
    ELSE BEGIN 

       IF i MOD modbas EQ 0 THEN BEGIN 

          IF NOT keyword_set(quiet) THEN $
             print,'Iter # '+strtrim(string(i),2)

             ;implement diagnostic

             this_diagnostic.iter=i
             this_diagnostic.grid=grid
             this_diagnostic.partnumber=int_tabulated(ygrid,10^(ygrid)*grid,/double)*alog(10.)
             ;old method! --> less accurate
             ;total(0.5*(grid[0:N-2]+grid[1:N-1])*(egrid[1:N-1]-egrid[0:N-2]))
             ;total(grid);this is wrong, it should be integrated instead
             this_diagnostic.tottemp=tottemp


             IF keyword_set(save_memory) AND (i LT niter) THEN BEGIN 
                IF ind_save MOD 3 EQ 0 THEN diagnostic=[diagnostic,this_diagnostic]
                ind_save=ind_save+1
             ENDIF $
             ELSE BEGIN 
                diagnostic=[diagnostic,this_diagnostic]
             ENDELSE

      ;expectation values of energy, number
      ;of particles etc... as a function of time!

             
             ;do plots if needed
             IF NOT keyword_set(noplot) THEN BEGIN 
                plot,egrid,abs(grid),/xlog,/ylog,yrange=yrange,xrange=xrange $
                     ,psym=-6,title='time '+strtrim(string(i),2),nsum=nsum
                oplot,egrid,-grid,color=2,psym=6

                oplot,10^ytherm*[1,1],10^!Y.crange,linestyle=1
                oplot,egrid,densmaxw*pg_maxwellian(egrid,etherm),color=12,thick=1,nsum=nsum
                
                IF keyword_set(doescape) THEN $
                   oplot,egrid,dgridescape,color=10
                wait,waitpar

             ENDIF ;plots

          ENDIF; diagnostic saving

    ENDELSE;normal diagnostic

ENDWHILE

lastdist=grid

IF keyword_set(doescape) THEN $
   IF keyword_set(relescape) THEN $
      esctype='RELATIVISTIC SQRT(E)' $
   ELSE $
      esctype='NON RELATIVISTIC SQRT(E)' $
ELSE BEGIN 
   esctype='NO ESCAPE'
   tauescape=-1
ENDELSE


ymin=min(ygrid)
ymax=max(ygrid)
dygrid=ygrid[1]-ygrid[0]
steps_per_decade=round(1/dygrid)


endtime=systime(1)

;now only output, later input will be implemented (or maybe not!)
IF doescape THEN $
  simpar={YMIN:ymin,YMAX:ymax,STEPS_PER_DECADE:steps_per_decade,ITER:double(niter), $
        DTIME_ITER:dt,DIMLESS_TIME_UNIT:th,AVCKOMEGA:avckomega,UTDIVBYUB:utdivbyub, $
        TAUESCAPE:tauescape,RELESCAPE:keyword_set(relescape),YTHERM:ytherm, $
        DENSITY:densmaxw,CLMBLOG:clmblog,THRESHOLD_ESCAPE_KEV:threshold_escape_kev, $
        COLLISION_STRENGTH_SCALE:collision_strength_scale,array_tauescape:array_tauescape} $
ELSE $
  simpar={YMIN:ymin,YMAX:ymax,STEPS_PER_DECADE:steps_per_decade,ITER:double(niter), $
        DTIME_ITER:dt,DIMLESS_TIME_UNIT:th,AVCKOMEGA:avckomega,UTDIVBYUB:utdivbyub, $
        NOESCAPE:1,YTHERM:ytherm, $
        DENSITY:densmaxw,CLMBLOG:clmblog, $
        COLLISION_STRENGTH_SCALE:collision_strength_scale};,array_tauescape:array_tauescape} $

IF doescape THEN $
total_diagnostic={diagnostic:diagnostic, energy:egrid,etherm:etherm,ytherm:ytherm, $
                  th:th,accelerationtype:'MILLER_FIX',escapetype:esctype, $
                  avckomega:avckomega,utdivbyub:utdivbyub,tauescape:tauescape, $
                  comp_time:endtime-startime,simpar:simpar} $
ELSE $
total_diagnostic={diagnostic:diagnostic, energy:egrid,etherm:etherm,ytherm:ytherm, $
                  th:th,accelerationtype:'MILLER_FIX',escapetype:esctype, $
                  avckomega:avckomega,utdivbyub:utdivbyub, $
                  comp_time:endtime-startime,simpar:simpar} 



END
