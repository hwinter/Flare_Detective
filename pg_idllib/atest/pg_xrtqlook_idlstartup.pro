;+
;
; This is executed at the startup of IDL and starts the XRT quicklook update job
; Written 04-DEC-2007 Paolo C. Grigis pgrigis@cfa.harvard.edu
; $Id: pg_xrtqlook_idlstartup.pro 24 2007-12-07 19:47:00Z pgrigis $
; 
;-

;remove_path,'myidllib';test the version to work without Paolo Grigis' IDL library
;add_path,'~/xrtqlook/idl/',/expand,/append

idlpath=get_logenv('XRT_QLOOK_IDL_DIR')
add_path,idlpath,/expand,/append

pg_update_xrtqlook

exit

END


