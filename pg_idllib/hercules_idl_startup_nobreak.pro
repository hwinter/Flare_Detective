;taken from PSH totalidl_startup, to use for hercules with hydrus
;x-server
;nobreak--> starts small script to prevent shell termination...
PRINT,"RUNNING hercules_idl_startup.pro..."

IF GETENV('RAPP_IDL_ROOT') NE '' THEN $
  add_path,GETENV('RAPP_IDL_ROOT'),/EXPAND,/APPEND,/QUIET

remove_path, GETENV('SSW')+'/radio/ethz/idl/atest'
add_path, GETENV('SSW')+'/radio/ethz/idl/atest',/expand,/quiet


device,retain=2,decomposed=0,true_color=16;,pseudo_color=8

;ps device:
olddisplay=!D.NAME
set_plot,'ps'
device,bits_per_pixel=8,/color
set_plot,olddisplay


remove_path, 'SSWoverrides'
IF GETENV('RAPP_IDL_ROOT') NE '' THEN add_path,GETENV('RAPP_IDL_ROOT')+'/SSWoverrides',/EXPAND,/QUIET

;print,'Compiling mpfit & tnmin...'

pg_compilelist 

;shell script to prevent premature break
$ ts &

PRINT,"...hercules_idl_startup.pro FINISHED!"

