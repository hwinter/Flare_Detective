;this routine returns the corrected countrates from the observing summary, in a rates[n_ebins,n_tbins] array,


FUNCTION hessi_corrected_os_countrate, time_intv, $
					time_arr=time_arr
	ro=OBJ_NEW('hsi_obs_summ_rate')
	ro->set,obs_time_interval=time_intv
	tmp=ro->getdata()
	time_arr=ro->get(/time)
	tmp=ro->corrected_countrate()
	OBJ_DESTROY,ro
	RETURN,tmp
END
