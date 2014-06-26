;+
; NAME: 
;
; pg_setup_spex  
;
; PURPOSE:
;
; starts a spex session, subtract background, select interval
;
; CATEGORY:
;        
; noninteractive spex utilities
;
; CALLING SEQUENCE:
;
; pg_setup_spex,sp_file,srm_file,sel_st
;
; INPUTS:
; 
; sp_file : name of spectrum fits file for spex to use
; srm_file: name of response fits file for spex to use
; sel_st  : structure with background and interval times selections
;           (uses the SPEX convention for variable naming)
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
; pg_setup_spex: used to communicate with spex
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
; written 27-NOV-2003 PG
;
;-

PRO pg_setup_spex,sp_file,srm_file,sel_st

   IF file_exist(sp_file) AND file_exist(srm_file) THEN BEGIN

      COMMON pg_setup_spex,pg_sel_st
      pg_sel_st=sel_st

      ;;start spex
      spex_proc,/cmode,input='data,hessi,front'
      ;;load files
      spex_proc,/cmode,input='_1file,'+sp_file+' !!' + $
                'dfile,'+srm_file+' !! graph'
      ;;subtract background
      spex_proc,/cmode,input='idl, COMMON pg_setup_spex !!' + $
                'energy_bands = pg_sel_st.energy_bands !!' + $
                'th_ytype     = pg_sel_st.th_ytype !!' + $
                'th_yrange    = pg_sel_st.th_yrange !!' + $
                'scale_bands  = pg_sel_st.scale_bands !!' + $
                'tb           = pg_sel_st.tb !! ' + $
                'back_order   = pg_sel_st.back_order !!' + $
                'check_defaults,0 !!' + $
                'use_band=-1 !! background !!' + $
                'tb           = pg_sel_st.tb !!' + $
                'use_band= 0 !! background !!' + $
                'use_band= 1 !! background !!' + $
                'use_band= 2 !! background !!' + $
                'use_band= 3 !! background !!' + $
                'graph'

      ;;select time interval
      spex_proc,/cmode,input='idl, COMMON pg_setup_spex !!' + $
                'xselect   = pg_sel_st.xselect !!' + $
                'idl, IF pg_sel_st.style_sel EQ ''regular'' THEN xselect=' + $
                '[min(pg_sel_st.xselect),max(pg_sel_st.xselect)] !!' + $
                'iavg      = pg_sel_st.iavg !!' + $
                'style_sel = pg_sel_st.style_sel !!' + $
                'select '
      
   ENDIF $
   ELSE print,'Invalid files!'

   RETURN

END
