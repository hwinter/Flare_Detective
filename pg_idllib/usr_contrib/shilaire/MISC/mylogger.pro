; PSH, 2002/03/12 
;
;




PRO mylogger,text,file=file,new=new

IF NOT KEYWORD_SET(file) THEN file='/global/hercules/users/shilaire/LOGS/TEMP.log'

IF KEYWORD_SET(new) THEN OPENW,lun1,file,/GET_LUN ELSE OPENW,lun1,file,/GET_LUN,/APPEND

PRINTF,lun1,text

FREE_LUN,lun1
END
