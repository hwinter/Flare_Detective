
device,retain=2,pseudo_color=8

add_path,GETENV('RAPP_IDL_ROOT')+'/shilaire',/EXPAND,/APPEND
remove_path, GETENV('SSW')+'/radio/ethz/idl/atest'
add_path, GETENV('SSW')+'/radio/ethz/idl/atest',/expand,/quiet
remove_path, 'SSWoverrides'
add_path,GETENV('RAPP_IDL_ROOT')+'/SSWoverrides',/EXPAND
;remove_hessi_atest

PRINT,'hedc_hec_startup.pro finished.'
