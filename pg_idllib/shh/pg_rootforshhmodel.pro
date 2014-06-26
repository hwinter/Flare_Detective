;+
; NAME:
;
; pg_rootforshhmodel
;
; PURPOSE:
;
; returns one or more values for spectral index and flux for photon spectra
; derived from cutoff electrons spectra 
;
; CATEGORY:
;
; rhessi spectrograms/fitting util
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
; Paolo Grigis, Institute for Astronomy, ETH Zurich
; pgrigis@astro.phys.ethz.ch 
;
; MODIFICATION HISTORY:
;
; 19-JUL-2007 pg written
;-

;.comp pg_rootforshhmodel

FUNCTION pg_rootforshhmodel,x,delta=delta,elenergy=elenergy,phenergy=phenergy $
                           ,goalgamma=goalgamma,f50=f50,loud=loud,outf50=outf50 $
                           ,outeta=outeta,turnover=turnover



  f50=fcheck(f50,1)*1d33;3.654*1d33

  nx=n_elements(x)
  outdelta=x*0.
  outf50=outdelta
  outeta=outdelta

  FOR i=0,nx-1 DO BEGIN 

     IF keyword_set(loud) THEN print,i

     ecutoff=x[i]

     ph=pg_sp_ecutoff_thick(elenergy=elenergy,phenergy=phenergy $
                           ,delta=delta,f50=f50,ecutoff=ecutoff $
                           ,turnover=turnover)


     indfit=where(phenergy GE 20 AND phenergy LE 80)

     yl=alog(ph[indfit])
     xl=alog(phenergy[indfit]/50.)

;     stop
;     resquad=pg_polyfit(xl,yl,degree=2)
     res2=poly_fit(xl,yl,2)
     
     resquad=res2[[2,1,0]]

     outf50[i]=exp(resquad[2])
     outdelta[i]=resquad[1] 
     outeta[i]=resquad[0] 

  ENDFOR

  RETURN,outdelta-goalgamma

END

