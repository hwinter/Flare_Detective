;+
;
; This is executed at the startup of IDL and starts the XRT GBAND update job
; This only adds to the path the IDL programs required for the snapview generation
; and calls pg_dogbandupdate. For more info on the processing, please read the
; header of pg_dogbandupdate.pro
;
; Written 29-APR-2008 Paolo C. Grigis pgrigis@cfa.harvard.edu
; 
; $Id: xrt_snpv_idlstartup.pro 39 2007-12-19 21:26:16Z pgrigis $
; 
;-


set_plot,'Z'

;idlpath=get_logenv('XRT_SNPV_IDL_DIR')
add_path,'/home/pgrigis/myidllib/',/expand,/append

pg_dogbandstuff

exit

END

