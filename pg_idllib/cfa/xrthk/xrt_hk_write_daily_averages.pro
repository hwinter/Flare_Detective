PRO xrt_create_daily_averages_test

;start_time='01-SEP-2006'
;end_time='01-SEP-2009'
;end_time='02-JAN-2009'

;hktag='ALL'
;data=xrt_get_hk_value(hktag,starttime,endtime,hkfileprefix='XRTD_STS')

res=xrt_hk_read_daily_averages('XRTD_TEMP12')
oktime=(res.time-anytim('01-JAN-2006'))/(365.25*24.0*3600.0)
plot,2006+oktime,res.value,yrange=[20,55],title=res.name,/yst,xrange=[2006.5,2010.0],/xst

END



PRO xrt_hk_write_daily_averages,hkdata,avgfiledir=avgfiledir,backupfile=backupfile

; =========================================================================
;		
;+
; PROJECT:
;       Solar-B / XRT
;
; NAME:
;
;       XRT_HK_WRITE_DAILY_AVERAGES
;
; CATEGORY:
;
;       XRT Housekeping info
;
;
; PURPOSE:
;
;       Write XRT housekeeping daily averages
;
;
; CALLING SEQUENCE:
;
;       xrt_hk_write_daily_averages,hktag,avgfiledir=avgfiledir
;
;
; INPUTS:
;
;       hkdata:     (structure) A structure with format 
;                   {time:time,value:value,name:hktag}
;
;
; KEYWORDS:
;       backupfile: if set, the old file is copied before being overwritten
;
;
; OPTIONAL INPUTS:
;
;      avgfiledir: location of daily average files (default: TBD)
;
;
; OUTPUT:
;
;
;
;
; EXAMPLE:
;
;       
;
; COMMON BLOCKS:
;
;       none
;
; PROCEDURE:
;
;       This routine reads in...
;
;
; KNOWN PROBLEMS:
;
; 
;
; NOTES:
;       
;      
; CONTACT:
;
;       Comments, feedback, and bug reports regarding this routine may be
;       directed to this email address:
;                xrt_manager ~at~ head.cfa.harvard.edu
;
;
;
; MODIFICATION HISTORY:
; 
progver='v2009.Jun.09'  ;--- P. Grigis written
;
;
;-
; =========================================================================


  ; define output dir
  avgfiledir=fcheck(avgfiledir,'/home/pgrigis/machd/dailyavdir/')

  ; OS dependent path separator
  ps=path_sep()

  thisfile=avgfiledir+ps+strupcase(hkdata.name)+'_daily_average.txt'

  IF keyword_set(backupfile) AND file_exist(thisfile) THEN BEGIN 
     file_copy,thisfile,thisfile+'.'+time2file(!stime)+'.backup',/overwrite
  ENDIF 



  openw,lun,thisfile,/get_lun

  printf,lun,'*********************************************'
  printf,lun,'    XRT DAILY AVERAGE VALUES: '+hkdata.name
  printf,lun,'*********************************************'

  FOR i=0L,n_elements(hkdata.time)-1 DO BEGIN 
     printf,lun,anytim(hkdata.time[i],/date_only,/ccsds)+'  '+string(hkdata.value[i],format='(f10.5)')
  ENDFOR 

  close,lun
  free_lun,lun


  
 
END
     
