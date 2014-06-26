; makes a pixon reconstruction for a simulated source.

PRO pro20021025_pixon,sourceFWHM

hessi_version,/release
simo=hsi_image()
pixsiz=1.
imgdim=128
timeintv=4.
gg = {gaussian_source_str} 
gg.xypos = [0.,0.] 
gg.tilt_angle_deg = 0. 
gg.amplitude = 1.0 
;==========================================================
gg.xysigma = FLOAT(sourceFWHM)/2.355*[1.,1.] 
;==========================================================
simo ->set, sim_model=gg,sim_photons_per_coll=60000,          	$
	sim_pixel_size=pixsiz, pixel_size=pixsiz,               $
	energy_band=[12.,25.] , sim_energy_band=[12.,25.],      $
	det_index=1+BYTARR(9),sim_det_index=1+BYTARR(9),        $
	time_range=[0.,timeintv],sim_time_range=[0.,timeintv],  $
	sim_image_dim=imgdim, image_dim=imgdim
simo->plot

simo->set,image_alg='pixon'
simo->set_no_screen_output
simo->set,det_index=[0,0,1,1,1,1,1,1,0],sim_det_index=[0,0,1,1,1,1,1,1,0]
simo->plot

map=make_hsi_map(simo)
SAVE,filename='~/sim_pixon_map_'+strn(sourceFWHM)+'.dat',map
END
