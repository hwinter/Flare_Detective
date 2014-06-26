;+
; NAME:
;
; pg_shs_2dimplotfitdist
;
; PURPOSE:
;
; plot & fit the 2-dimensional distribution of the models paramters
; 
;
; CATEGORY:
;
; shs tool
;
; CALLING SEQUENCE:
;
; parms=pg_shs_plotfitdist(parx,pary)
;
; INPUTS:
;
; parx,pary: array with the x,y values of the parameter      
;
; OPTIONAL INPUTS:
;
;
; KEYWORD PARAMETERS:
;
;
; OUTPUTS:
;
;
; OPTIONAL OUTPUTS:
;
;
;
; COMMON BLOCKS:
;
;
;
; SIDE EFFECTS:
;
;
;
; RESTRICTIONS:
;
;
;
; PROCEDURE:
;
;
;
; EXAMPLE:
;
;
;
; AUTHOR:
;
; Paolo Grigis, Institute of Astronomy, ETH Zurich
; pgrigis@astro.phys.ethz.ch
;
; MODIFICATION HISTORY:
;
; 10-SEP-2004 written PG
; 15-SEP-2004 better psym check, binoplot keyword added PG
;-

forward_function mpfit2dpeak_gauss


FUNCTION pg_shs_2dimplotfitdist,parx,pary,logfit=logfit,xrange=xrange $
            ,yrange=yrange,xrmin=xrmin,xrmax=xrmax,yrmin=yrmin,yrmax=yrmax $
            ,t3hick=t3hick,lambda=lambda,status=status,verbose=verbose $
            ,psym=psym,binoplot=binoplot,_extra=_extra


t3hick=fcheck(t3hick,3)
quiet=1-keyword_set(verbose)

IF NOT exist(psym) THEN BEGIN
   ;user defined plot symbol: small filled circle
   d=0.45;circle radius
   N=32.
   A = FINDGEN(N+1) * (!PI*2./N)
   USERSYM, d*COS(A), d*SIN(A), /FILL

   plotsymbol=8 
ENDIF ELSE plotsymbol=psym

logfit=1

IF keyword_set(logfit) THEN BEGIN 

   logparx=alog(parx)
   xrmin=fcheck(xrmin,min(logparx))
   xrmax=fcheck(xrmax,max(logparx))
   logpary=alog(pary)
   yrmin=fcheck(yrmin,min(logpary))
   yrmax=fcheck(yrmax,max(logpary))

   xmed=pg_medmoments(logparx)
   ymed=pg_medmoments(logpary)

   pg_make_std_binning,avg=xmed[0],stdev=xmed[1],lambda=lambda $
      ,rmin=xrmin-2*xmed[1],rmax=xrmax+2*xmed[1] $
      ,outmin=xoutmin,outmax=xoutmax,binsize=xbinsize,nbins=xnbins

   pg_make_std_binning,avg=ymed[0],stdev=ymed[1],lambda=lambda $
      ,rmin=yrmin-2*ymed[1],rmax=yrmax+2*ymed[1] $
      ,outmin=youtmin,outmax=youtmax,binsize=ybinsize,nbins=ynbins

  ; stop

   IF n_elements(xrange) NE 2 THEN BEGIN
      xrange=[xoutmin-0.1*(xoutmax-xoutmin),xoutmax+0.1*(xoutmax-xoutmin)]
      xrange=exp(xrange)
   ENDIF
   IF n_elements(yrange) NE 2 THEN BEGIN
      yrange=[youtmin-0.1*(youtmax-youtmin),youtmax+0.1*(youtmax-youtmin)]
      yrange=exp(yrange)
   ENDIF


   denstr=pg_get2dimdensity(logparx,logpary,maxx=xoutmax,maxy=youtmax $
      ,minx=xoutmin,miny=youtmin,nbinsx=xnbins,nbinsy=ynbins)

   ;fitting part...

   ;parinfo=replicate({fixed:0,limits:[0,0],limited:[0,0]},7)
   ;parinfo[0].fixed=1
   ;parinfo[6].limited=[0,0]
   ;parinfo[6].limits=[-10*!DPi,10*!DPi]

   yfit=mpfit2dpeak(denstr.density,parms,denstr.x,denstr.y, /tilt $
       ,quiet=quiet,status=status,_extra=_extra $
       ,estimates=[0d,10.,xmed[1],ymed[1],xmed[0],ymed[0],3.])

;check
;  gfit=gauss2dfit(denstr.density,gparms,denstr.x,denstr.y, /tilt)
;  print,'gparms',gparms

;  parms=gparms

;      ,estimates=[0d,10.,xmed[1],ymed[1],xmed[0],ymed[0],3.] $
;      ,quiet=quiet,status=status)
;      ,parinfo=parinfo,quiet=quiet,status=status)

   
   Nx=512
   Ny=512
   xx=findgen(Nx)/(Nx-1)*(xoutmax-xoutmin)+xoutmin
   yy=findgen(Ny)/(Ny-1)*(youtmax-youtmin)+youtmin
   x=xx#replicate(1,Ny)
   y=yy##replicate(1,Nx)

   yfit2=mpfit2dpeak_gauss(x, y, parms, /tilt)

;   contour,yfit2,exp(xx),exp(yy),/xlog,/ylog $
;      ,xrange=xrange,yrange=yrange,/xstyle,/ystyle $
;      ,levels=[0.0001,0.1,10]

   ;levels: 1 sigma, 2 sigma, 3 sigma
   lev=parms[0]+parms[1]*exp(-0.5*[5,3,1]^2)

   contour,yfit2,exp(xx),exp(yy),/xlog,/ylog $
      ,xrange=xrange,yrange=yrange,/xstyle,/ystyle $
      ,levels=lev,_extra=_extra

   contour,yfit2,exp(xx),exp(yy) $
      ,levels=lev[1],/overplot,thick=t3hick

   oplot,parx,pary,psym=plotsymbol

   IF keyword_set(binoplot) THEN BEGIN
      FOR ii=0,xnbins-1 DO oplot,exp(denstr.x[ii])*[1,1],10^!Y.crange
      FOR jj=0,ynbins-1 DO oplot,10^!X.crange,exp(denstr.y[jj])*[1,1]
   ENDIF


   return,parms

ENDIF ELSE BEGIN

 ;nolog...  
 
ENDELSE



END
