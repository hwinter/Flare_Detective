;+
; NAME:
;
; pg_shs_load
;
; PURPOSE:
;
; load useful data for the shs project
;
; CATEGORY:
;
; util for shs project
;
; CALLING SEQUENCE:
;
; arrayofpinters=pg_shs_load([basename=basename])
;
; INPUTS:
;
; basename: used to differentiate among different fittings procedures
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
; AUTHOR:
;
; Paolo Grigis, Institute of Astronomy, ETH Zurich
; 
;
; MODIFICATION HISTORY:
;
; 17-DEC-2003 written
;
;-

FUNCTION pg_shs_load,basename=basename

@~/work_frometh/shs/eventinfo/eventinfo.pro

rootdir='~/work_frometh/shs/'
totflares=33

stp=ptrarr(totflares)

basename=fcheck(basename,'sfit')

FOR n_flare=0,totflares-1 DO BEGIN 

   fitres=rootdir+'fitsresults/'+basename+'_'+strtrim(string(n_flare),2)+ $
          '.fits'
   IF file_exist(fitres) THEN BEGIN
      sp_st=mrdfits(fitres,1)
      sp_st=join_struct({n_flare:n_flare},sp_st)   
      stp[n_flare]=ptr_new(sp_st)
   ENDIF

ENDFOR

RETURN,stp

END


