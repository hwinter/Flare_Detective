; PURPOSE : to test (& better understand) Jmm's "hsi_new_flare_find.pro"

; PSH 2001/03/26 

pro test_new_flare_find

bla=mrdfits('HESSI/test_data/hsi_20000831_1557_000.fits',6,head)
NTIMES=bla.N_TIME_INTV
tim_arr=[bla.UT_REF,bla.UT_REF+(NTIMES-1)*bla.TIME_INTV]
  ;dt_data=tim_arr	; to be checked & better understood...
    dt_data=fltarr(1455)
    dt_data=dt_data+4.
    ;dt_data=4.

;load & uncompress the rates...
donnee=lonarr(9,NTIMES)
bla=mrdfits('HESSI/test_data/hsi_20000831_1557_000.fits',7,head)
for i=0,8 do donnee(i,*)=HSI_OBS_SUMM_DECOMPRESS(bla(*).COUNTRATE(i))
; take the energy range that interests/concerns me :
data=total(donnee,1)

hsi_new_flare_find,tim_arr,dt_data,data,nflares, $
                        bck_time, bck_rate, threshold_rate, $
                        st_times, pk_times, en_times, $
                        peak_data, total_counts

print,nflares
print,bck_time
print,bck_rate
print,threshold_rate
print,st_times
print,pk_times
print,en_times
print,peak_data
print,total_counts
end
