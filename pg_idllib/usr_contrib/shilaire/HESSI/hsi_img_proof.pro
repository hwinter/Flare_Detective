;
; light curves of each detector, 12-25 and 25-50, front and rear
; sc panel, 12-25 and 25-50 (back proj), in ROI AND FULL SUN !!!!
; images using all collimators, with different img_alg
;
; pass resulting image to the simulation software...
;
; also try: longer time_range
;
eband1=[12,25]
eband2=[25,50]
pix_siz=1
img_dim=128
;====================================================================


time_range='2002/02/26 '+['10:26:44','10:26:56']
xyoffset=[950,-115]


;====================================================================
; lightcurves for each segments:

hedc_win,900,nb=1
plot_sc_lc,time_range,eband=eband1
hedc_win,900,nb=2
plot_sc_lc,time_range,eband=eband1,/REAR
hedc_win,900,nb=3
plot_sc_lc,time_range,eband=eband2
hedc_win,900,nb=4
plot_sc_lc,time_range,eband=eband2,/REAR
;====================================================================
; images for each detector:

;use sc_panel.... ???

hedc_win
imo=hsi_image()
imo->set,time_range=time_rng
imo->set,xyoffset=xyoffset,pixel_size=pix_siz,image_dim=img_dim
imo->set,uniform=1	;!!!!!!!!!!!!!!!!!!!!!!


;OBJ_DESTROY,imo
END

