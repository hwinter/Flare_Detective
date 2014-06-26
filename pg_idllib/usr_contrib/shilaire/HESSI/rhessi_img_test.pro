;PRO rhessi_img_test

t1=systim2anytim()
imo=hsi_image()
imo->set,time_range='2002/02/20 '+['11:06:08','11:07:08']
imo->set,xyoffset=[907,261],image_dim=128,pixel_size=1
imo->set,det_index=[0,0,1,1,1,1,1,1,0]
imo->set,FRONT=1,REAR=0
imo->set,energy_band=[25,50]
imo->set,image_alg='pixon'
imo->set_no_screen_output
imo->plot,charsize=1.3

t2=systim2anytim()
PRINT,t2-t1
END

; If BackProj takes ~30 sec on helene-2,
; CLEAN takes an additional ~20 secs
; PIXON takes ?
; MEM-Sato: ~2.2 min
; MEMVIS: failed after 13 min.
; FFit: forget it, it's cheating or assuming too much, here.

;t1=systim2anytim()
;imo->plot,charsize=1.3
;t2=systim2anytim()
;PRINT,t2-t1
;=====================================================================================================================

add_path,'/global/saturn/home/csillag/idl/andreimage/'
add_path,'/global/saturn/home/csillag/idl/hxrbsqueue/'

hessi_ct,/QUICK
imo=hsi_image()
imo->set,time_range='2004/08/02 '+['04:54:52','04:55:08']
imo->set,xyoffset=[0,0],image_dim=128,pixel_size=16
imo->set,det_index=[0,0,0,0,0,0,1,1,1]
imo->set,energy_band=[12,25]	;[6,25] works...
imo->set,image_alg='clean'
imo->set_no_screen_output
im=imo->getdata()
;imo->plot,charsize=1.3,/LIMB

imo->fitswrite,fitsfile='tmp.fits',/CREATE
