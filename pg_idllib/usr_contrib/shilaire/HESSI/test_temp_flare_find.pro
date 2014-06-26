; PURPOSE : to test (& bettre understand) Jmm's "hsi_temp_flare_find.pro"

; PSH 2001/03/26 


; RESTRICTIONS : in hsi_temp_flare_find.pro , at line 416
		; put bck_time = -1 in comments !!!


pro test_temp_flare_find

bla=mrdfits('HESSI/test_data/hsi_20000831_1557_000.fits',6,head)
NTIMES=bla.N_TIME_INTV
tim_arr=[bla.UT_REF,bla.UT_REF+NTIMES*bla.TIME_INTV]
  ;dt_data=tim_arr	; to be checked & better understood...
  dt_data=fltarr(1455)
  dt_data=dt_data+4.

;load & uncompress the rates...
donnee=lonarr(9,NTIMES)
bla=mrdfits('HESSI/test_data/hsi_20000831_1557_000.fits',7,head)
for i=0,8 do donnee(i,*)=HSI_OBS_SUMM_DECOMPRESS(bla(*).COUNTRATE(i))
; take the energy range that interests/concerns me :
data=total(donnee,1)

;get mod_var...(according to Jmm's "hsi_find_flares.pro"
bla=mrdfits('HESSI/test_data/hsi_20000831_1557_000.fits',10,head)
mod_var=float(bla.MOD_VARIANCE)/10.0	;THIS IS WHAT IS PLOTTED BY oso->plot
mod_var=reform(mod_var[0,*]+mod_var[1,*])/2.0

; background time and rate ... this one is still not clear...
bla=mrdfits('/global/helene/users/shilaire/HESSI/test_data/hsi_20000831_1557_000.fits',25,head)
bck_time=bla.BCK_TIME
tmp=bla.BCK_RATE
bck_rate=total(tmp)	; I assume that's what we want...

print,anytim(tim_arr,/yoh)
print,max(donnee)
print,max(data),n_elements(data)
help,mod_var,/st
print,anytim(bck_time,/yoh)
print,bck_rate

hsi_temp_flare_find,tim_arr,dt_data,data,mod_var,bck_time,bck_rate, $
	st_times,peak_times,en_times

end
