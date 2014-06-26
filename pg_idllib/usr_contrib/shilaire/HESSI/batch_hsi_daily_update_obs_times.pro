;This batch file is to be used as a cronjob. The cronjob entry should look
;like:
;
;
;	20 0 * * * /global/hercules/users/shilaire/HESSI/cron/cron_hsi_daily_update_obs_times > /dev/null
;
;
;
;	PSH, 2002/08/02
;


today=systim2anytim()	; in anytim double units
;today='2002/08/30 00:00:01'

PRINT,'.......... DOING '+anytim(today,/date_only,/ECS)+' .......................'
hsi_obs_status_update_files, anytim(today,/date_only)-2*86400.

PRINT,'IDL-OK'

IDLversion=float(strmid(!version.release,0,3))
IF IDLversion EQ 5.4 THEN FLUSH,-1
END
