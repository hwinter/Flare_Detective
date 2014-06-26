;+
; NAME:
;       pg_make_std_binning
;
; PURPOSE: 
;       
;       returns a binning centered on AVG and with a width of LAMBDA*STDEV
;       comprising the range [RMIN,RMAX]. The new range boundaries are
;       returned as [OUTMIN,OUTMAX] and the binsize is given by BINSIZE
;
;
; HISTORY
;       written 08-SEP-2004
;       
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;-

PRO pg_make_std_binning,avg=avg,stdev=stdev,lambda=lambda $
            ,rmin=rmin,rmax=rmax,outmin=outmin,outmax=outmax $
            ,binsize=binsize,nbins=nbins


   lambda=fcheck(lambda,0.5d)
   
   binsize=lambda*stdev

   leftpoint=avg-0.5d*binsize
   rightpoint=avg+0.5d*binsize

   nbins=1
   
   IF leftpoint GT rmin THEN BEGIN
      totspace=leftpoint-rmin
      leftbins=ceil(totspace/binsize)
      outmin=leftpoint-leftbins*binsize
      nbins=nbins+leftbins
   ENDIF ELSE outmin=leftpoint

   IF rightpoint LT rmax THEN BEGIN
      totspace=rmax-rightpoint
      rightbins=ceil(totspace/binsize)
      outmax=rightpoint+rightbins*binsize
      nbins=nbins+rightbins
   ENDIF ELSE outmin=leftpoint

END
