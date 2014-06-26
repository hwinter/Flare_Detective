;*********************************
; PSH's IDL startup file on carme:
;*********************************


add_path,GETENV('RAPP_IDL_ROOT')+'/shilaire',/EXPAND,/APPEND

device,pseudo_color=8
device,retain=2

;myct3,ct=1

;set PS device to 8 bits:
olddisplay=!D.NAME
set_plot,'ps'
device,bits_per_pixel=8,/color
set_plot,olddisplay

remove_path, 'SSWoverrides'
add_path,GETENV('RAPP_IDL_ROOT')+'/SSWoverrides',/EXPAND

;END message
print,"............................................FINISHED PSH's startup."


