;+
; NAME:
;
; pg_shs_plotfitdist
;
; PURPOSE:
;
; plot & fit the distribution of the models paramters
; 
;
; CATEGORY:
;
; shs tool
;
; CALLING SEQUENCE:
;
; parms=pg_shs_plotfitdist(par)
;
; INPUTS:
;
; par: array with the values of the parameter      
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
; 08-SEP-2004 written PG
;
;-

FUNCTION pg_shs_plotfitdist,par,logfit=logfit,xrange=xrange,yrange=yrange $
                           ,rmin=rmin,rmax=rmax,_extra=_extra


IF keyword_set(logfit) THEN BEGIN 

   logpar=alog(par)
   rmin=fcheck(rmin,min(logpar))
   rmax=fcheck(rmax,max(logpar))

   IF n_elements(xrange) NE 2 THEN BEGIN
      xrange=[rmin-0.1*(rmax-rmin),rmax+0.1*(rmax-rmin)]
      xrange=exp(xrange)
   ENDIF

   yrange=fcheck(yrange,[0,15])

   med=median(logpar)
   medvar=total(abs(logpar-med))/(n_elements(logpar))

   pg_make_std_binning,avg=med,stdev=medvar,lambda=0.5 $
      ,rmin=rmin,rmax=rmax,outmin=outmin,outmax=outmax $
      ,binsize=newbinsize,nbins=newnbins

   pg_plot_histo,par,min=exp(outmin),max=exp(outmax),/xlog $
      ,binsize=newbinsize,histo=histo,x_edges=x_edges,/noplot


   parms=pg_fit_gaussian(x_edges,histo,parguess=[1d,med,medvar] $
                         ,/quiet,bestnorm=bestnorm)


   avg=parms[1]
   stdev=parms[2]

   pg_make_std_binning,avg=avg,stdev=stdev,lambda=0.5 $
            ,rmin=rmin,rmax=rmax,outmin=outmin,outmax=outmax $
            ,binsize=newbinsize2,nbins=newnbins

   pg_plot_histo,par,min=exp(outmin),max=exp(outmax),/xlog,xrange=xrange $
      ,binsize=newbinsize2,histo=histo,x_edges=x_edges,yrange=yrange,_extra=_extra
 

   oplot,avg*[1,1],!y.crange,linestyle=2
   oplot,(avg+stdev)*[1,1],!y.crange,linestyle=1
   oplot,(avg-stdev)*[1,1],!y.crange,linestyle=1
   oplot,(avg+3*stdev)*[1,1],!y.crange,linestyle=1
   oplot,(avg-3*stdev)*[1,1],!y.crange,linestyle=1

 
   print,newbinsize,newbinsize2
   parms[0]=parms[0]*newbinsize2
   xx=findgen(1001)/1000*(alog(xrange[1])-alog(xrange[0]))+alog(xrange[0])
   oplot,xx,pg_gauss(xx,parms)



   return,parms

ENDIF ELSE BEGIN

   
   rmin=fcheck(rmin,min(par))
   rmax=fcheck(rmax,max(par))

   IF n_elements(xrange) NE 2 THEN BEGIN
      xrange=[rmin-0.1*(rmax-rmin),rmax+0.1*(rmax-rmin)]
   ENDIF

   yrange=fcheck(yrange,[0,15])

   med=median(par)
   medvar=total(abs(par-med))/(n_elements(par))

   pg_make_std_binning,avg=med,stdev=medvar,lambda=0.5 $
      ,rmin=rmin,rmax=rmax,outmin=outmin,outmax=outmax $
      ,binsize=newbinsize,nbins=newnbins

   pg_plot_histo,par,min=outmin,max=outmax $
      ,binsize=newbinsize,histo=histo,x_edges=x_edges,/noplot

   parms=pg_fit_gaussian(x_edges,histo,parguess=[1d,med,medvar] $
                         ,/quiet,bestnorm=bestnorm)


   avg=parms[1]
   stdev=parms[2]

   pg_make_std_binning,avg=avg,stdev=stdev,lambda=0.5 $
            ,rmin=rmin,rmax=rmax,outmin=outmin,outmax=outmax $
            ,binsize=newbinsize2,nbins=newnbins

   pg_plot_histo,par,min=outmin,max=outmax,xrange=xrange $
      ,binsize=newbinsize2,histo=histo,x_edges=x_edges,yrange=yrange,_extra=_extra
 

   oplot,avg*[1,1],!y.crange,linestyle=2
   oplot,(avg+stdev)*[1,1],!y.crange,linestyle=1
   oplot,(avg-stdev)*[1,1],!y.crange,linestyle=1
   oplot,(avg+3*stdev)*[1,1],!y.crange,linestyle=1
   oplot,(avg-3*stdev)*[1,1],!y.crange,linestyle=1

 
   print,newbinsize,newbinsize2
   parms[0]=parms[0]*newbinsize2
   xx=findgen(1001)/1000*(xrange[1]-xrange[0])+xrange[0]
   oplot,xx,pg_gauss(xx,parms)



   return,parms


ENDELSE



END
