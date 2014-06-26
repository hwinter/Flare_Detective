PRINT,"RUNNING PSH's totalidl_startup.pro..."

IF GETENV('RAPP_IDL_ROOT') NE '' THEN add_path,GETENV('RAPP_IDL_ROOT'),/EXPAND,/APPEND,/QUIET

;add_path, '/global/tethys/usr/local/rsi/libidl/ragview', /expand
;add_path, '/global/tethys/usr/local/rsi/libidl/ragview/ssw_debug'
;add_path, '/global/helene/data/ftp/pub/saturn/ragview/ethz/idl', /expand

remove_path, GETENV('SSW')+'/radio/ethz/idl/atest'
add_path, GETENV('SSW')+'/radio/ethz/idl/atest',/expand,/quiet

;ps device:
olddisplay=!D.NAME
set_plot,'ps'
device,bits_per_pixel=8,/color
;help,/device
set_plot,olddisplay

device,retain=2,pseudo_color=8

;--------------------------------------------
;chianti stuff:
	;!xuvtop=getenv('SSW')+'/packages/chianti/dbase
	;!ioneq_file=getenv('SSW')+'
;--------------------------------------------


remove_path, 'SSWoverrides'
IF GETENV('RAPP_IDL_ROOT') NE '' THEN add_path,GETENV('RAPP_IDL_ROOT')+'/SSWoverrides',/EXPAND,/QUIET

PRINT,"...totalidl_startup.pro FINISHED!"
;ragview
