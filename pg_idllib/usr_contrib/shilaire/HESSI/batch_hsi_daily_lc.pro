;
;This batch file is to be used as a cronjob. The cronjob entry should look
;like:
;
;
;	29 0 * * * /global/hercules/users/shilaire/HESSI/cron/cron_hsi_daily_lc > /dev/null
;
;
;
;	HESSI lightcurves are generated automatically for the previous third day.
;	The previous seventh day is also redone (in case data got better...).
;	
;	PSH, 2002/03/17
;

;==================================================================================================================================================
PRO import_daily_lc_into_hedc, ECSdate

	outdir='/global/hercules/users/shilaire/HEDC/NEWDATA_daily_lc'

	;;following not necessary, as they'll be overwritten.
	;spawn,'\rm '+outdir+'/HEDC_DP_lc99_DAILYLC.info'
	;spawn,'\rm '+outdir+'/HEDC_DP_lc99_DAILYLC.png'
	;spawn,'\rm '+outdir+'/HEDC_EVENT_DAILYLC.einfo'
	
	OPENW,lun,outdir+'/HEDC_EVENT_DAILYLC.einfo',/GET_LUN
	PRINTF,lun,'.S12_HLE_CODE: HEC_DAILYLC'
	PRINTF,lun,'.DAT_HLE_CREATIONDATE: '+anytim2oracle(systim2anytim())
	PRINTF,lun,'.DAT_HLE_STARTDATE: '+anytim2oracle(ECSdate)
	PRINTF,lun,'.I08_HLE_STARTTIME: 0'
	PRINTF,lun,'.DAT_HLE_ENDDATE: '+anytim2oracle(anytim(ECSdate)+86399.999D)
	PRINTF,lun,'.I08_HLE_ENDTIME: 86399'
	PRINTF,lun,'.BOO_HLE_SIMULATEDDATA: 0'
	PRINTF,lun,'.TXT_HLE_COMMENTS: Red: 3-25 keV; Yellow: 25-100 keV; Green: 100-17000 keV. Log scale, bottom line is 10^2 cts/s, top is 10^5 cts/s. //'
	FREE_LUN,lun

	OPENW,lun,outdir+'/HEDC_DP_lc99_DAILYLC.info',/GET_LUN
	PRINTF,lun,'.S12_ANA_CODE: HEC_DAILYLC'
	PRINTF,lun,'.C03_ANA_PRODUCTTYPE: LC'
	PRINTF,lun,'.DAT_ANA_CREATIONDATE: '+anytim2oracle(systim2anytim())
	PRINTF,lun,'.DAT_ANA_STARTDATE: '+anytim2oracle(anytim(ECSdate))
	PRINTF,lun,'.I08_ANA_STARTTIME: 0'
	PRINTF,lun,'.DAT_ANA_ENDDATE: '+anytim2oracle(anytim(ECSdate)+86399.999D)
	PRINTF,lun,'.I08_ANA_ENDTIME: 86399'
	PRINTF,lun,'.I05_ANA_MINENERGY: 3.0'
	PRINTF,lun,'.I05_ANA_MAXENERGY: 17000.0'
	PRINTF,lun,'.F04_ANA_LTCTIMERES: 4.0'
	PRINTF,lun,'.BOO_ANA_FRONTSEGMENT: 1'
	PRINTF,lun,'.BOO_ANA_REARSEGMENT: 1'
	PRINTF,lun,'.S09_ANA_SUBCOLLUSED: 111111111'
	PRINTF,lun,'.BOO_ANA_SIMULATEDDATA: 0'
	PRINTF,lun,'.TXT_ANA_COMMENTS: Red: 3-25 keV; Yellow: 25-100 keV; Green: 100-17000 keV. Log scale, bottom line is 10^2 cts/s, top is 10^5 cts/s. //'
	FREE_LUN,lun

	spawncmd='cp /global/helene/users/www/staff/shilaire/hessi/daily_lc/HESSI_lc_'+time2file(anytim(ECSdate,/date_only),/date_only)+'.png '+outdir+'/HEDC_DP_lc99_DAILYLC.png'
	SPAWN,spawncmd
	
	CD,'/global/hercules/users/shilaire/HEDC/import',current=currentdir
	spawncmd='source import_daily_lc.so'
	SPAWN,spawncmd
	CD,currentdir

END
;==================================================================================================================================================



;CATCH,err_st
;IF err_st ne 0 THEN BEGIN
;	GOTO,NEXTPLEASE
;	err_st=0	
;	exit,status=33,/NO_CONFIRM
;ENDIF

remove_path,'atest'	; because is_ieeee_big.pro in ethz/idl/atest/ fucks up...
doGIF=1
wwwdir='/global/saturn/data/www/staff/shilaire/hessi/daily_lc/'

today=systim2anytim()	; in anytim double units

	curday=today-86400D*5D
	PRINT,'.......... DOING '+anytim(curday,/date_only,/ECS)+' .......................'
	hsi_daily_lc, anytim(curday,/date_only),/Zbuff,GIF=doGIF,/FITS,outdir=wwwdir,/OBSSUMM

	curday=today-86400D*15D
	PRINT,'.......... DOING '+anytim(curday,/date_only,/ECS)+' .......................'
	hsi_daily_lc, anytim(curday,/date_only),/Zbuff,GIF=doGIF,/FITS,outdir=wwwdir,/OBSSUMM

	curday=today-86400D*30D
	PRINT,'.......... DOING '+anytim(curday,/date_only,/ECS)+' .......................'
	hsi_daily_lc, anytim(curday,/date_only),/Zbuff,GIF=doGIF,/FITS,outdir=wwwdir,/OBSSUMM
	;import_daily_lc_into_hedc, anytim(curday,/date_only)
	;hsi_daily_lc_v2, anytim(curday,/date_only),/Zbuff,/GIF,/FITS,outdir=wwwdir

	PRINT,'IDL-OK'
END
