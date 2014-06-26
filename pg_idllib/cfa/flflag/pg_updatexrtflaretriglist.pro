;
; This is the main file run as a CRON job to update the XRT flare flag list
;


idl_progdir=get_logenv('PRO_DIR')
FlareFlagList=get_logenv('XRT_FLARE_TRIG_LIST')
npastdays=get_logenv('NPASTDAYS')

add_path,idl_progdir,/expand,/append

now=get_logenv('XRT_NOW')
IF strlen(now) EQ 0 THEN now=anytim(!stime) ELSE now=anytim(now)

TimeInterval=now-[round(float(npastdays))*24d*3600d,0]

pg_xrtflareflag_updatelist,TimeInterval=TimeInterval,FlareFlagList=FlareFlagList


exit


