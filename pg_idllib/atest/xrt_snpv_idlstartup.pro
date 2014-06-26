;+
;
; This is executed at the startup of IDL and starts the XRT snapview update job
; This only adds to the path the IDL programs required for the snapview generation
; and calls xrt_snpv_update. For more info on the processing, please read the
; header of xrt_snpv_update.pro
;
; Written 04-DEC-2007 Paolo C. Grigis pgrigis@cfa.harvard.edu
;         19-DEC-2007 changed names
; 
; $Id: xrt_snpv_idlstartup.pro 39 2007-12-19 21:26:16Z pgrigis $
; 
;-


set_plot,'Z'

idlpath=get_logenv('XRT_SNPV_IDL_DIR')
add_path,idlpath,/expand,/append

xrt_snpv_update

exit

END


