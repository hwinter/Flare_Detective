add_path,'/global/carme/home/shilaire/IDL',/EXPAND,/APPEND
add_path, '/global/tethys/usr/local/rsi/libidl/ragview', /expand
add_path, '/global/tethys/usr/local/rsi/libidl/ragview/ssw_debug'

;ps device:
olddisplay=!D.NAME
set_plot,'ps'
device,bits_per_pixel=8,/color
;help,/device
set_plot,olddisplay

psh_init
print,'........................psh_init has been run'
