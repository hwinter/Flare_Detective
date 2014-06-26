;+
; NAME:
;
; pg_apar2physpar
;
; PURPOSE:
;
; transform an apar array to physical parameters
;
; CATEGORY:
;
; shs project util, spex util
;
; CALLING SEQUENCE:
;
; physpar=pg_apar2physpar(apar_arr, [output keyword])
;
; INPUTS:
;
; apar_arr: array NxM, N=10 for now, M: number of time intervals
; output keyword, one of: /temp,/flux,/ecut,/em,/spindex,/bistemp,/bisem
;
; OUTPUTS:
;
; physpar: an array M with the values of the chosen parameter
;
;
; COMMON BLOCKS:
;
; none
;
; SIDE EFFECTS:
;
;
;
; RESTRICTIONS:
;
; assumes for now that f_model f_multi_spec is used
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
; pgrigis@astro.pyhs.ethz.ch
; 
; MODIFICATION HISTORY:
;
; 05-FEB-2004 written P.G.
;
;-

FUNCTION pg_apar2physpar,apar_arr,apar_sig=apar_sig,temp=temp,errtemp=errtemp,ecut=ecut $
                        ,errecut=errecut,em=em,errem=errem,eref=eref $
                        ,spindex=spindex,errspindex=errspindex,bistemp=bistemp $
                        ,bisem=bisem,errbisem=errbisem,sqemt=sqemt $
                        ,bissqemt=bissqemt,epivot=epivot



   IF keyword_set(temp)      THEN yarray=kev2kel(apar_arr[1,*])
   IF keyword_set(errtemp)   THEN yarray=kev2kel(apar_sig[1,*])
   IF keyword_set(em)        THEN yarray=apar_arr[0,*]
   IF keyword_set(errem)     THEN yarray=apar_sig[0,*]   
   IF keyword_set(spindex)   THEN yarray=apar_arr[5,*]
   IF keyword_set(errspindex)THEN yarray=apar_sig[5,*]   
   IF keyword_set(ecut)      THEN yarray=apar_arr[8,*]
   IF keyword_set(errecut)   THEN yarray=apar_sig[8,*]
   IF keyword_set(bistemp)   THEN yarray=kev2kel(apar_arr[3,*])
   IF keyword_set(errbistemp)THEN yarray=kev2kel(apar_sig[3,*])
   IF keyword_set(bisem)     THEN yarray=apar_arr[2,*]
   IF keyword_set(errbisem)  THEN yarray=apar_sig[2,*]

   IF keyword_set(sqemt)     THEN yarray=sqrt(apar_arr[0,*])*apar_arr[1,*]
   IF keyword_set(bissqemt)  THEN yarray=sqrt(apar_arr[2,*])*apar_arr[3,*]

   IF n_elements(eref) NE 0  THEN BEGIN

      IF NOT exist(apar_sig) THEN BEGIN
         out=pg_apar2flux_fmultispec({apar_arr:apar_arr,epivot:fcheck(epivot,50)},eref,/no_errors)
         yarray=out.flux
      ENDIF ELSE BEGIN
         out=pg_apar2flux_fmultispec({apar_arr:apar_arr,apar_sigma:apar_sig $
                                     ,epivot:fcheck(epivot,50)},eref)
         yarray=out.eflux
      ENDELSE

   ENDIF


   RETURN, yarray


END
