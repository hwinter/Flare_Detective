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



FUNCTION xrt_hk_read_daily_averages,hktag,avgfiledir=avgfiledir

; =========================================================================
;		
;+
; PROJECT:
;       Solar-B / XRT
;
; NAME:
;
;       XRT_HK_READ_DAILY_AVERAGES
;
; CATEGORY:
;
;       XRT Housekeping info
;
;
; PURPOSE:
;
;       Read XRT housekeeping FITS files and creates daily averages
;
;
; CALLING SEQUENCE:
;
;       hkdata=xrt_hk_read_daily_averages(hktag,avgfiledir=avgfiledir)
;
;
; INPUTS:
;
;       hktag:      (string) definition of the housekeeping variable to be
;                   returned (e.g. "TMP11C"). Accepts arrays, but this works
;                   only if all the tags are in the same file.
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

  thisfile=avgfiledir+ps+strupcase(hktag)+'_daily_average.txt'

  dstring=rd_ascii(thisfile)

  time=anytim(strmid(dstring[3:*],0,10))
  value=float(strmid(dstring[3:*],12,20))

  RETURN,{time:time,value:value,name:hktag}

 
END
     
