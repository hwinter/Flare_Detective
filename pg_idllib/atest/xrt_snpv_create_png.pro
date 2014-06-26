;+
; NAME:
;
; xrt_xnpv_create_png
;
; PURPOSE:
;
; Produces XRT "snapview" observing summary as hourly png files
;
; CATEGORY:
;
; snapview observing summary for XRT
;
; CALLING SEQUENCE:
;
; xrt_snpv_create_png,time_intv,xrt_qlook_images_dir,xrt_qlook_html_dir [,/quicklook]
;
; INPUTS:
;
; time_intv: a time interval in anytim compatible format
; xrt_qlook_images_dir: a string with the directory for storing the images generated
; xrt_qlook_html_dir: a string with the directory for storing the html files
;                     generated
;
;  
; OPTIONAL INPUTS:
;
; quicklook keyword: if set, the quicklook data is used rather than the regular archive
;
; KEYWORD PARAMETERS:
;
; xrt_use_qlook_catalog: if set, uses the quicklook catalog instead of the
; normal (level 0) catalog. The quicklook catalog should be used for recent
; (less than 7-10 day old) data.
;
; OUTPUTS:
;
; NONE, several files generated
;
; OPTIONAL OUTPUTS:
;
;
;
; COMMON BLOCKS:
;
;
;
; SIDE EFFECTS:
;
;
;
; RESTRICTIONS:
;
;
;
; PROCEDURE:
;
;
;
; EXAMPLE:
;
;
;
; AUTHOR:
;
; Paolo Grigis, CfA
; pgrigis@cfa.harvard.edu
;
; $$
;
; MODIFICATION HISTORY:
;
; 05-DEC-2007 PG written 
; 07-DEC-2007 PG splitted html & png functionality, renamed
; 
;-


PRO xrt_snpv_create_png,time_intv,xrt_qlook_images_dir,xrt_qlook_html_dir $
                ,quicklook=quicklook,logfilelun=logfilelun,imsize=imsize $
                ,logfilename=logfilename,xrt_use_qlook_catalog=xrt_use_qlook_catalog




  loadct,0
  linecolors
;  !p.background=255
;  !p.color=0
  !p.charsize=3

imsize=fcheck(imsize,'LARGE')

tstart=time_intv[0]
tend=time_intv[1]

ndays=(tend-tstart)/86400.

basdir=xrt_qlook_images_dir
dispdir=xrt_qlook_html_dir
ps=path_sep()

IF xrt_use_qlook_catalog THEN BEGIN 

   IF imsize EQ 'LARGE' THEN $
      im_basefilename='xrt_snapview_qlook_' $
   ELSE $
      im_basefilename='xrt_snapview_qlook_small_' 

ENDIF $
ELSE BEGIN 

   IF imsize EQ 'LARGE' THEN $
      im_basefilename='xrt_snapview_' $
   ELSE $
      im_basefilename='xrt_snapview_small_'
            
ENDELSE

;.run
FOR i=0,ndays-1 DO BEGIN


   thisday=anytim(tstart+i*86400.,/ex,/date_only)

   IF keyword_set(logfilelun) THEN BEGIN 
      openu,logfilelun,logfilename,/append
      printf,logfilelun,'Now processing: '+anytim(thisday,/vms,/date_only)
      close,logfilelun
   ENDIF

   
   thisdir=basdir+smallint2str(thisday[6],strlen=4)+ps $
                 +smallint2str(thisday[5],strlen=2)+ps $
                 +smallint2str(thisday[4],strlen=2)+ps

   IF NOT file_exist(thisdir) THEN file_mkdir,thisdir
   IF NOT file_exist(dispdir) THEN file_mkdir,dispdir

   FOR j=0,23 DO BEGIN 

      IF keyword_set(logfilelun) THEN BEGIN 
         openu,logfilelun,logfilename,/append
         printf,logfilelun,'Hour: '+smallint2str(j,strlen=2)
         close,logfilelun
      ENDIF

      thistime=tstart+i*86400.+j*3600.
      print,'Now making snapview image for '+anytim(thistime,/vms)
      filename=thisdir+im_basefilename+time2file(thistime)+'.png'
      pg_xrt_qlook,thistime+[0,3600],outfilename=filename,/zbuffer $
                  ,background_color=255,plot_color=0,goes_color=0 $
                  ,linfiltthick=3,lmthick=1,imsize=imsize $
                  ,xrt_use_qlook_catalog=xrt_use_qlook_catalog

      print,filename
      
   ENDFOR
 
ENDFOR

END





