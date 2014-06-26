;COPY/PASTE


hsi_switch,/SIM

simo=hsi_image()
det_index=BYTARR(9)
gg = {gaussian_source_str} 
;--------- parameters-----------
coll=3
pixsiz=1.
imgdim=128
timeintv=12.
eband=[12,25]
det_index[coll]=1B
gg.xypos = [0.,0.] 
gg.tilt_angle_deg = 0. 
gg.amplitude = 1.0 
gg.xysigma = 0.001*[1.,1.]/2.355 
;-------------------------------
simo ->set, sim_model=gg,sim_photons_per_coll=60000,            $
        sim_pixel_size=pixsiz, pixel_size=pixsiz,               $
        energy_band=eband , sim_energy_band=eband,              $
        det_index=det_index,sim_det_index=det_index,	        $
        time_range=[0.,timeintv],sim_time_range=[0.,timeintv],  $
        sim_image_dim=imgdim, image_dim=imgdim
simo->plot

detres=[2.26,3.92,6.79,11.76,20.36,35.27,61.08,105.8,183.2]
res_incr=detres[coll]/4.
n_incr=FIX(1410./res_incr)
PRINT,'N_increments: '+strn(n_incr)+' of '+strn(res_incr)+'"'
A=FLTARR(n_incr)

FOR i=0,n_incr-1 DO BEGIN                                       &$
        xyoffset=[410.-i*res_incr,10.]                          &$
        simo->set,sim_xyoffset=xyoffset, xyoffset=xyoffset      &$
        tmp=simo->getdata()                                     &$
        peakvalue=MAX(tmp)                                      &$
        tmp=simo->get(/binned_n_event)                          &$
        counts=tmp[coll,0]                                      &$
        cbe=simo->getdata( CLASS_NAME = 'HSI_Calib_eventlist' ) &$
        pbar=mean( (*cbe[coll,0]).gridtran*(1.+(*cbe[coll,0]).modamp*cos((*cbe[coll,0]).phase_map_ctr)))	&$
        A[i]=peakvalue*pbar/counts 										&$
	PRINT,'...................................COMPLETED: '+strn(FLOAT(i+1)/n_incr*100.)+' %'		&$
ENDFOR ;i

text='Subcollimator '+strn(coll+1)
PLOT,410-FINDGEN(n_incr)*res_incr,A,			$
	xtit='Map center, X coordinate (arcsecs)',     	$
	ytit='Relative amplitude A',tit=text;,psym=-7

END
