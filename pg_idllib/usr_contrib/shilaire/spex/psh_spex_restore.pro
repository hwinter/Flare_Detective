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
;	psh_spex_restore,'SEARCH_for_Ecoto/20020421/hsi_spectrum_20020421_003500.fits','SEARCH_for_Ecoto/20020421/hsi_srm_20020421_003500_a1.fits',mrdfits('SEARCH_for_Ecoto/20020421/fitting_A1.fits',2)
;
; AUTHOR:
;
; Paolo C. Grigis, Institute for Astronomy, ETH Zurich
; pgrigis@astro.phys.ethz.ch
;
; MODIFICATION HISTORY:
;
; written 27-NOV-2003 PG
; 2004/08/03: Modified and renamed by PSH.
;-

PRO psh_spex_restore,sp_file,srm_file,sel_st

   IF file_exist(sp_file) AND file_exist(srm_file) THEN BEGIN

;RESOLVE_ROUTINE,'psh_model_components',/COMPILE_FULL_FILE,/EITHER

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
      
	;; other stuff:
	spex_proc,/cmode,input='idl, COMMON pg_setup_spex !!' + $
		'f_model,'+pg_sel_st.f_model+' !!' + $
		'erange   = pg_sel_st.erange !!' + $
		'spyrange   = pg_sel_st.spyrange !!' + $
		'free   = pg_sel_st.free !!' + $
		'ifirst   = pg_sel_st.ifirst !!' + $
		'ilast   = pg_sel_st.ilast '

	;; MISC.
	spex_proc,/cmode,input='eplot,1'
	spex_proc,/cmode,input='display'

	;; restoring apar_arr...
		FOR i=0L,N_ELEMENTS(pg_sel_st.apar_arr[0,*])-1 DO BEGIN
			FOR j=0,N_ELEMENTS(pg_sel_st.apar_arr[*,0])-1 DO BEGIN
				spex_proc,/cmode,input='idl,apar_arr['+strn(j)+','+strn(i)+']='+strn(pg_sel_st.apar_arr[j,i])				
			ENDFOR
		ENDFOR
	spex_proc,/cmode,input='apar=apar_arr[*,0]'	;;temporary hack?	
	
	
	spex_proc,/cmode,input='check_defaults,1'	;;back to 'interactive mode'...
	spex_proc
   ENDIF $
   ELSE print,'Invalid files!'

   RETURN

END
