; PSH 2001/09/06
;
; This simple routine can be called anywhere and will add to the
; file hedc_log.txt the line of text.
;
;  Will create the file hedc_log.txt if it does not exist.
;
; PSH, 2001/11/02 : rewritten




PRO hedc_add_to_log,text,dir=dir,new=new,file=file

IF NOT KEYWORD_SET(dir) THEN dir=getlog('HEDC_LOG_DIR') ELSE dir=dir_slash(dir)

IF KEYWORD_SET(file) THEN filename=dir+file ELSE filename=dir+'failed_IDL_jobs.log'
IF KEYWORD_SET(new) THEN OPENW,lun1,filename,/GET_LUN ELSE OPENW,lun1,filename,/GET_LUN,/APPEND

PRINTF,lun1,text

FREE_LUN,lun1
END
