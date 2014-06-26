PRO testor5
print,'fdfggfgfgggfcvxnjtuktu'


spo=hsi_spectrum()
spo->set,obs_time_interval='01-sep-00 '+['00:08:01','00:08:05']
spo->set,det_index_mask=bytarr(9)+1b,/sp_semi_calibrated,data_unit='flux'
spo->set,sp_energy_binning=5,sp_time_interval=4.
;spo->set,time_range=[0.,4.] ; if I use this, the thing crashes...

spo->plot

blabla=spo->get()
print,anytim(blabla.absolute_time_range,/ECS)
;2000/09/01 00:06:29.417 2000/09/01 00:09:36.425

obj_destroy,spo
END
