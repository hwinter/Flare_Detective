;
; This is the main file run as a CRON job to update the HK plots
;

idl_progdir=get_logenv('PRO_DIR')
hk_2colfiledir=get_logenv('DATA_DIR')
hk_outimdir=get_logenv('GIF_DIR')

time=anytim(!stime)

add_path,idl_progdir,time=time,hk_2colfiledir=hk_2colfiledir,hk_outimdir=hk_outimdir

END


