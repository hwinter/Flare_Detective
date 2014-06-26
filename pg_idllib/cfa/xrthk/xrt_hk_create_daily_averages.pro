PRO xrt_create_daily_averages_test

start_time='01-SEP-2006'
end_time='01-SEP-2009'
;end_time='02-JAN-2009'

;hktag='ALL'
;data=xrt_get_hk_value(hktag,starttime,endtime,hkfileprefix='XRTD_STS')

xrt_hk_create_daily_averages,'XRTD_TEMP12',start_time=start_time,end_time=end_time, $
                          hkfileprefix='XRTD_STS',res=res



start_time='06-SEP-2008'
end_time='12-SEP-2008'
start_time='03-SEP-2008'
end_time='08-SEP-2008'

start_time='07-SEP-2008'
end_time='12-SEP-2008'


start_time='01-SEP-2008'
end_time='15-SEP-2008'

xrt_hk_create_daily_averages,'XRTD_TEMP12',start_time=start_time,end_time=end_time, $
                          hkfileprefix='XRTD_STS',res=res,nforce=3,/loud


start_time='01-SEP-2006'
end_time='01-SEP-2009'
;end_time='02-JAN-2009'

;hktag='ALL'
;data=xrt_get_hk_value(hktag,starttime,endtime,hkfileprefix='XRTD_STS')
xrt_hk_create_daily_averages,'XRTD_TEMP12',start_time=start_time,end_time=end_time, $
                          hkfileprefix='XRTD_STS',res=res,nforce=3,/loud



start_time='01-SEP-2006'
end_time='01-SEP-2009'
xrt_hk_create_daily_averages,'XRTD_TEMP11',start_time=start_time,end_time=end_time, $
                          hkfileprefix='XRTD_STS',res=res,nforce=3,/loud

END



pro xrt_hk_create_daily_averages,hktag,start_time=start_time,end_time=end_time, $
                                 hkfileprefix=hkfileprefix, $
                                 avgfiledir=avgfiledir, $
                                 hkfiledir=hkfiledir, $
                                 loud=loud,res=res, $
                                 nforce_comp_days=nforce_comp_days

; =========================================================================
;		
;+
; PROJECT:
;       Solar-B / XRT
;
; NAME:
;
;       XRT_HK_CREATE_DAILY_AVERAGES
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
;       hkdata=xrt_get_hk_value,hktag,startdate=startdate,enddate=enddate, $
;                               hkfileprefix=hkfileprefix, $
;                               avgfiledir=avgfiledir, $
;                               hkfiledir=hkfiledir, $
;                               loud=loud
;
;
; INPUTS:
;
;       hktag:      (string) definition of the housekeeping variable to be
;                   returned (e.g. "TMP11C"). Accepts arrays, but this works
;                   only if all the tags are in the same file.
;       start_date: (string or double) start of the time
;                   interval that is checked for missing images. Can be in 
;                   any format accepeted by ANYTIM.
;       end_date:   (string or double) end of the time
;                   interval that is checked for missing images. Can be in 
;                   any format accepeted by ANYTIM.
;
; OPTIONAL INPUTS:
;
;       hkfileprefix: selects which HK status file to read from (normally, one
;                      of 'XRT_STS', 'MDP_STS','XRTD_STS','XRTE_STS'.
;                      Default is 'XRT_STS'. Scalar only. If hktag is given as
;                      an array, make sure all the tags are in the same file.
;       hkfiledir: (string) Root of the directory trees where HK FITS reside. The default
;                      is '/archive/hinode/cmn/'. 
;       nforce_comp_days:
;       loud:       (0 or 1) If set, debugging output is shown.
;
;
; OUTPUT:
;       avgfiledir: location of daily average files
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
progver='v2009.Jun.08'  ;--- P. Grigis written
;
;
;-
; =========================================================================


  ;number of days in the interval that computation is forced for 
  ;note that the forced computation happens at the end of the interval
  nforce_comp_days=round(fcheck(nforce_comp_days,10))

  ; define archive directory
  dir = fcheck(hkfiledir,'/archive/hinode/cmn/')

  ; define output dir
  avgfiledir=fcheck(avgfiledir,'/home/pgrigis/machd/dailyavdir/')

  ; OS dependent path separator
  ps=path_sep()

  ;HK type specification
  hkfileprefix=fcheck(hkfileprefix,'XRT_STS')

  ;HK data file directory
  dir=dir+hkfileprefix+ps

  ;convert inputs to anytim format: external representation
  s_time = anytim(start_time,/date_only)
  e_time = anytim(end_time,/date_only)

  ;one day in seconds
  oneday=24d *3600d

  ;compute how many days there are in the interval
  ndays=ceil((e_time-s_time)/oneday+1)

  ;create array for each day in the interval at 12:00
  alldayarray=s_time+oneday*findgen(ndays)

  ;mask: which new days need to be computed?
  computethisday=bytarr(ndays)

;;  for now assume scalar tags           ;;;check how many tags are requested
;;  this may (will?) be vectorized later ;;ntags=n_elements(hktag)

  
  ;daily average file for this HK tag value
  thisfile=avgfiledir+ps+strupcase(hktag)+'_daily_average.txt'



  ;check whether average daily files exist
  IF NOT file_exist(thisfile) THEN BEGIN
     ;if not, compute *all* days in the interval
     computethisday[*]=1B
  ENDIF $
  ELSE BEGIN

     IF keyword_set(loud) THEN print,'Now reading '+thisfile

     ; if the file exist, read its contents
     hkdata=xrt_hk_read_daily_averages(hktag,avgfiledir=avgfiledir)
        
     ;this are the computed times
     computed_days=hkdata.time
        
     ;which days do I need to compute an update for?
     FOR i=0L,n_elements(alldayarray)-1 DO BEGIN
        ;only where there's no data within a
        ;short time interval of the average time at noon
        IF min(abs(computed_days-alldayarray[i])) GT 100 THEN computethisday[i]=1B

     ENDFOR 
     
  ENDELSE 
  


;Even though a value may be computed already,
;there's the possibility it was based on uncomplete coverage
;for that day, therefore, we force computation of the last
;days in the time interval (controlled by NFORCE_COMP_DAYS variable).
;Note that it can be set to 0 to avoid forcing computation.
IF nforce_comp_days GE 1 THEN BEGIN 
   computethisday[(ndays-nforce_comp_days)>0:*]=1B
ENDIF 


;find index of days to compute
ind=where(computethisday EQ 1,countdaytocompute)

;do I need to compute anything at all?
IF countdaytocompute GT 0 THEN BEGIN 

   ;;IF keyword_set(loud) THEN print,'Will compute:'+anytim(alldayarray[ind],/vms)


   ;value is undefined if no useful data found in the acrhive
   nan=!values.f_nan
  
   ;time of the new average data
   newtime=alldayarray[ind]
   ;new average datas
   newdata=replicate(nan,countdaytocompute)

   ;reads HK FITS files and compute average
   FOR i=0L,countdaytocompute-1 DO BEGIN

      IF keyword_set(loud) THEN print,'Now processing HK data for '+anytim(newtime[i],/vms,/date_only)
      data=xrt_get_hk_value(hktag,newtime[i],newtime[i]+oneday,hkfileprefix=hkfileprefix)


      IF size(data,/tname) EQ 'STRUCT' THEN BEGIN 
      ;need to remove spurious 0 in FITS files values 
         indokdata=where(data.value NE 0,countokdata)
         IF countokdata GT 0 THEN newdata[i]=average(data.value[indokdata]) 
      ENDIF 
   ENDFOR 

   

   ;if old data exists
   IF size(hkdata,/tname) EQ 'STRUCT' THEN BEGIN 
                                ;intersperse new and all data by using the sort trick
      alltime=[hkdata.time,newtime]
      allvalue=[hkdata.value,newdata]
  
      ;;IF keyword_set(loud) THEN print,'Times:'+anytim(alltime,/vms)

 
      sortind=bsort(alltime)
      alltime2=alltime[sortind]
      allvalue2=allvalue[sortind]

      indok=uniq(alltime2)

      res={time:alltime2[indok],value:allvalue2[indok],name:hktag}


   ENDIF $
   ELSE BEGIN 
      res={time:newtime,value:newdata,name:hktag}
   ENDELSE 


   ;remove data from 18 and 19 JAN 2008 because the FITS files contain corrupted data for these days day
   ind=where(abs(res.time-anytim('18-JAN-2008')) LT 100 OR abs(res.time-anytim('19-JAN-2008')) LT 100,count)
   IF count GT 0 THEN res.value[ind]=!Values.f_nan

   xrt_hk_write_daily_averages,res,avgfiledir=avgfiledir,/backupfile

ENDIF $
ELSE BEGIN 
   
   res=hkdata

ENDELSE 

RETURN 



END
     
