;hessi_version,/release
;remove_hessi_atest

hessi_ct
imo54321=hsi_image()
imo54321->set,time_range='2002/02/26 '+['10:26:44','10:26:56']
imo54321->set,xyoffset=[0,0],image_dim=128,pixel_size=16
wdef,0
imo54321->plot,/limb,charsize=1.2

imo54321->set,xyoffset=[950,-115],pixel_size=1,det_index_mask=[0,0,1,1,1,1,1,1,0]
imo54321->plot,/limb,charsize=1.2

wdef,1
imo54321->set,image_alg='clean'
imo54321->set_no_screen_output
imo54321->plot,/limb,charsize=1.2
OBJ_DESTROY,imo54321
END
