;+
; NAME:
;
;   pg_quickpivot
;
; PURPOSE:
;
;   quick routine for finding pivot point information etc.
;
; CATEGORY:
; 
;   pivot-point related stuff
;
; CALLING SEQUENCE:
;
;  
;
; INPUTS:
;
;
;
; OPTIONAL INPUTS:
;
;
;
; KEYWORD PARAMETERS:
;
;
;
; OUTPUTS:
;
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
;   Paolo Grigis
;   pgrigis@astro.phys.ethz.ch
;
; MODIFICATION HISTORY:
;
;   03-MAR-2006 written PG
;   20-MAR-2006 added numpoints outputPG
;
;-

FUNCTION pg_quickpivot,flux,spindex,minspindex=minspindex,maxspindex=maxspindex,enorm=enorm


   minspindex=fcheck(minspindex,3.)
   maxspindex=fcheck(maxspindex,9.)
   enorm=fcheck(enorm,40.)

   ind=where(spindex GE minspindex AND spindex LE maxspindex,count)
   
   IF count GE 2 THEN BEGIN 
      
      sixlin,alog(flux[ind]),spindex[ind],a,siga,b,sigb

      i=0;y vs. x
      ;i=2

      slope=b[i]
      sigslope=sigb[i]
      h=a[i]
      sigh=siga[i]

      epiv=enorm*exp(1/slope)
      depiv=epiv/slope^2*sigslope
      fpiv=exp(-h/slope)
      dfpiv=fpiv/slope^2*sqrt(h^2*sigslope^2+slope^2*sigh^2)

      good=finite(epiv)

      ans={epiv:epiv,fpiv:fpiv,depiv:depiv,dfpiv:dfpiv,okres:good, $
           numpoints:count}

   ENDIF ELSE BEGIN 
      nan=!Values.f_nan
      ans={epiv:nan,fpiv:nan,depiv:nan,dfpiv:nan,okres:0,numpoints:0}
   ENDELSE


   RETURN,ans

END
