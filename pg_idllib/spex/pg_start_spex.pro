;+
; NAME: 
;
; pg_start_spex  
;
; PURPOSE:
;
; starts a spex session, loading sp & srm files (similar to
; pg_setup_spex, but no background subtraction and time interval
; selection is performed)
;
; CATEGORY:
;        
; noninteractive spex utilities
;
; CALLING SEQUENCE:
;
; pg_setup_spex,sp_file,srm_file
;
; INPUTS:
; 
; sp_file : name of spectrum fits file for spex to use
; srm_file: name of response fits file for spex to use

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
; none (comunication with spex is done using common blocks and the
; spex_proc command
;
; OPTIONAL OUTPUTS:
;
;
;
; COMMON BLOCKS:
;
;
; SIDE EFFECTS:
;
; start a SPEX session (or change the current session)
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
; Paolo C. Grigis, Institute for Astronomy, ETH Zurich
; pgrigis@astro.phys.ethz.ch
;
; MODIFICATION HISTORY:
;
; written 19-APR-2003 PG, based on pg_setup_spex
;
;-

PRO pg_start_spex,sp_file,srm_file

   IF file_exist(sp_file) AND file_exist(srm_file) THEN BEGIN

      ;;start spex
      spex_proc,/cmode,input='data,hessi,front'
      ;;load files
      spex_proc,/cmode,input='_1file,'+sp_file+' !!' + $
                'dfile,'+srm_file+' !! graph'


      spex_proc,/cmode,input='th_ytype,1 !! ' + $
                'energy_bands,3,6,6,12,12,25,25,100 !!' + $
                'scale_bands,3,1,1.5,0.5 !! th_yrange,1e-4,1e3 !! graph'
      
   ENDIF $
   ELSE print,'Invalid files!'

   RETURN

END
