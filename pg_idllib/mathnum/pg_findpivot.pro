;+
; NAME:
;      pg_findpivot
;
; PROJECT:
;      diffusion & acceleration (plasma physics)
;
; PURPOSE: 
;      find the coordinates of the pivot point
;
; EXPLICATION:
;      
;
; CALLING SEQUENCE:
;     
;
; INPUTS:
;       
;     
; OUTPUTS:
;      
;      
; KEYWORDS:
;       
;
; HISTORY:
;       13-JAN-2006 written
;       01-FEB-2006 added count check
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;       pgrigis@astro.phys.ethz.ch
;-

FUNCTION pg_findpivot,spindex,fnorm,enorm,minrange=minrange,maxrange=maxrange,err=err

      minrange=fcheck(minrange,2.)
      maxrange=fcheck(maxrange,10.)

      ind=where(spindex GT minrange AND spindex LT maxrange,count)

      IF count LT 2 THEN BEGIN 

         nan=!values.f_nan
         sixnan=replicate(nan,6)
         fitres={fpiv:nan,epiv:nan,enorm:enorm $
                ,sixlin_a:sixnan,sixlin_b:sixnan,sixlin_siga:sixnan,sixlin_sigb:sixnan}
         err=1

         RETURN,fitres

      ENDIF


      spind=spindex[ind]
      fn=fnorm[ind]

      sixlin,alog(fn),spind,a,siga,b,sigb
     
      fitres={fpiv:exp(1d /b[0])^(-a[0]),epiv:enorm*exp(1d /b[0]),enorm:enorm $
             ,sixlin_a:a,sixlin_b:b,sixlin_siga:siga,sixlin_sigb:sigb}
     
      ;print,'EPIV: '+string(fitres.epiv,format='(f9.2)')+' keV'
      ;print,'FPIV: '+string(fitres.fpiv,format='(e12.2)')+' keV'


      RETURN,fitres
      
END


