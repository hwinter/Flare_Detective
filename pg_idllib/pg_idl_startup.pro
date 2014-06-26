PRINT,"This is Paolo Grigis personal startup procedure."

pglibpath='~/myidllib'

add_path,'/home/pgrigis/myidllib/usr_contrib/coyote/',/expand

add_path,pglibpath,/expand,/append
set_logenv,'PGLIBPATH',pglibpath

;IF GETENV('RAPP_IDL_ROOT') NE '' THEN add_path,GETENV('RAPP_IDL_ROOT'),/EXPAND,/APPEND,/QUIET

;ps device:
olddisplay=!D.NAME
set_plot,'ps'
device,bits_per_pixel=8,/color
;help,/device
set_plot,olddisplay

device,retain=2,pseudo_color=8

search_network,/enable

pg_compilelist;needed for avoid MPFIT conflicts with limits() function
