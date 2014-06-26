PRO rhessi_particle_rates, time_intv
	mro=hsi_qlook_monitor_rate()			
	mro->set,obs_time_interval=time_intv
	mr=mro->getdata()
		
	!P.MULTI=[0,1,2]
	mro->plot, tag_name='particle_rate',channel=0
	mro->plot, tag_name='particle_rate',channel=1
	OBJ_DESTROY, mro
END


