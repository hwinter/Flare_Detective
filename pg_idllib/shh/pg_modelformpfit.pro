;+
; NAME:
;
; pg_modelformpfit
;
; PURPOSE:
;
; fit best delta and flux for SHH/modeling project (electron spectrum with low
; energy cutoff)
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

;.comp  pg_modelformpfit


FUNCTION pg_modelformpfit,flux,par,elenergy=elenergy,phenergy=phenergy $
                         ,debug=debug,turnover=turnover

  ;stop

  f=par[0]
  delta=par[1]

  IF NOT keyword_set(turnover) THEN $
     print,'Calling pg_modelformpfit with delta= '+strtrim(delta,2)+' and f= '+strtrim(f,2) $
  ELSE $
     print,'Calling pg_modelformpfit (turnover) with delta= '+strtrim(delta,2) $
          +' and f= '+strtrim(f,2)



  ;find emin and emax

  IF keyword_set(debug) THEN emax=212 ELSE BEGIN 
     emax = pg_zbrent( 10, 500, func_name='pg_rootforshhmodel',goalgamma=-1.7 $
                       ,f50=f, delta=delta,elenergy=elenergy,phenergy=phenergy $
                       ,turnover=turnover)
  ENDELSE

  print,'Found emax: '+strtrim(emax,2)

  IF keyword_set(debug) THEN emin=89. ELSE BEGIN 
     emin = pg_zbrent( 10, 500, func_name='pg_rootforshhmodel',goalgamma=-2.6 $
                       ,f50=f, delta=delta,elenergy=elenergy,phenergy=phenergy $
                       ,turnover=turnover)
  ENDELSE

  print,'Found emin: '+strtrim(emin,2)

  ;
  
  IF keyword_set(debug) THEN n=5 ELSE n=30

  e=dindgen(n)/(n-1)*(emax-emin)+emin

  ;stop

  ;print,'[   testing 19-JUL-2007] Nflux before'+string(n_elements(flux2))

  ;flux1=flux2

  res=pg_rootforshhmodel(e,delta=delta,elenergy=elenergy,phenergy=phenergy $
                        ,goalgamma=0.,f50=f,outf50=outf50,turnover=turnover)

  ;print,' avec andre Nflux after'+string(n_elements(flux2))

 ; stop

  print,'Found curve between emin and emax'

  x=outf50
  y=res


  RETURN,interpol(y,x,flux)

END
