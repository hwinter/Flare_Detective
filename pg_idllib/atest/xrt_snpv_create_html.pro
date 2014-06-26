;+
; NAME:
;
; xrt_snpv_create_html
;
; PURPOSE:
;
; Produces XRT snapview HTML files for the web browsing
;
; CATEGORY:
;
; snapview util for XRT
;
; CALLING SEQUENCE:
;
; xrt_snpv_create_html,time_intv,xrt_qlook_images_dir,xrt_qlook_html_dir [,/quicklook]
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
; $Id: xrt_snpv_create_html.pro 44 2008-01-11 14:33:04Z pgrigis $
;
; MODIFICATION HISTORY:
;
; 07-DEC-2007 PG written 
; 
;-


PRO xrt_snpv_create_html,time_intv,xrt_qlook_images_dir,xrt_qlook_html_dir $
                ,quicklook=quicklook,logfilelun=logfilelun,imsize=imsize $
                ,logfilename=logfilename,xrt_use_qlook_catalog=xrt_use_qlook_catalog


  imsize=fcheck(imsize,'LARGE')


  IF xrt_use_qlook_catalog THEN BEGIN 

     IF imsize EQ 'LARGE' THEN BEGIN 
        im_basefilename='xrt_snapview_qlook_'
        html_basefilename='xrt_snapview_qlook_'
     ENDIF $
     ELSE BEGIN 
        im_basefilename='xrt_snapview_qlook_small_'
        html_basefilename='xrt_snapview_qlook_small_'
     ENDELSE
    
  ENDIF $
  ELSE BEGIN 
 
    IF imsize EQ 'LARGE' THEN BEGIN 
       im_basefilename='xrt_snapview_'
       html_basefilename='xrt_snapview_'     
    ENDIF $
    ELSE BEGIN
       im_basefilename='xrt_snapview_small_'
       html_basefilename='xrt_snapview_small_'     
    ENDELSE 
  ENDELSE


  tstart=time_intv[0]
  tend=time_intv[1]

  ndays=(tend-tstart)/86400.

  basdir=xrt_qlook_images_dir
  dispdir=xrt_qlook_html_dir
  ps=path_sep()


  FOR i=0,ndays-1 DO BEGIN

     thisday=anytim(tstart+i*86400.,/ex,/date_only)


   
     thisdir=basdir+smallint2str(thisday[6],strlen=4)+ps $
                   +smallint2str(thisday[5],strlen=2)+ps $
                   +smallint2str(thisday[4],strlen=2)+ps

     IF NOT file_exist(thisdir) THEN file_mkdir,thisdir
     IF NOT file_exist(dispdir) THEN file_mkdir,dispdir



   ;produce htmlfile

   thisday=anytim(thisday,/date_only)
   
   htmlfilename=dispdir+html_basefilename+time2file(thisday,/date_only)+'.html'

   IF keyword_set(logfilelun) THEN BEGIN 
      openu,logfilelun,logfilename,/append
      printf,logfilelun,'Creating HTML file '+htmlfilename
      close,logfilelun
   ENDIF


   nextdayfile =html_basefilename+time2file(thisday+86400.,/date_only)+'.html'
   prevdayfile =html_basefilename+time2file(thisday-86400.,/date_only)+'.html'
   nextwkfile  =html_basefilename+time2file(thisday+7.*86400.,/date_only)+'.html'
   prevwkfile  =html_basefilename+time2file(thisday-7.*86400.,/date_only)+'.html'
   nextmonthfile  =html_basefilename+time2file(thisday+30.*86400.,/date_only)+'.html'
   prevmonthfile  =html_basefilename+time2file(thisday-30.*86400.,/date_only)+'.html'
   nextyearfile  =html_basefilename+time2file(thisday+365.*86400.,/date_only)+'.html'
   prevyearfile  =html_basefilename+time2file(thisday-365.*86400.,/date_only)+'.html'


   thisday=anytim(thisday,/ex)
   daystring=smallint2str(thisday[4],strlen=2)
   monthstring=smallint2str(thisday[5],strlen=2)
   yearstring=smallint2str(thisday[6],strlen=4)
   ;nextday=anytim(thisday+86400.)
   ;nextdaystring=smallint2str(nextday[4],strlen=2)
   ;nextmonthstring=smallint2str(nextday[5],strlen=2)
   ;nextyearstring=smallint2str(nextday[6],strlen=4)

   curdir=curdir()
   cd,basdir
   imlist=file_search(yearstring+ps+monthstring+ps+daystring+ps+im_basefilename+'*.png')
   cd,curdir

   head=['<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML//EN">', $
         '<html> <head>', $
         '<title>Created by IDL</title>', $
         '</head>', $
         ' ', $
         '<body>', $
         '<h2>']

   body='Previous: <a href="'+prevdayfile+'">day</a> &nbsp; <a href="'+prevwkfile+'">week</a>' + $
        '&nbsp; <a href="'+prevmonthfile+'">month</a> &nbsp; <a href="'+prevyearfile+'">year</a> '+ $
        '&nbsp;&nbsp;&nbsp;&nbsp;Next: <a href="'+nextdayfile+'">day</a>&nbsp; <a href="'+nextwkfile + $
        '">week</a> &nbsp; <a href="'+nextmonthfile+'">month</a> &nbsp;'+ $
        '<a href="'+nextyearfile+'">year</a> <BR>'+ $
        '<a href="http://kurasuta.cfa.harvard.edu/cgi-bin/VSO/prod/vsoui.pl?'+ $
        'startyear='+yearstring+'&startmonth='+monthstring+'&startday='+daystring+ $
        '&starthour=00&startminute=00&endyear='+yearstring+'&endmonth='+monthstring+ $
        '&endday='+daystring+'&endhour=23&endminute=59&provider=SAO">VSO data for this day</a><BR></h2>'
 


   FOR k=0,n_elements(imlist)-1 DO BEGIN 
      thishour=smallint2str(k,strlen=2)
      nexthour=smallint2str(k+1,strlen=2)
      body=[body,'<IMG SRC="../'+imlist[k]+'">', $
            '<h3><a href="http://kurasuta.cfa.harvard.edu/cgi-bin/VSO/prod/vsoui.pl?'+ $
            'startyear='+yearstring+'&startmonth='+monthstring+'&startday='+daystring+ $
            '&starthour='+thishour+'&startminute=00&endyear='+yearstring+'&endmonth='+monthstring+ $
            '&endday='+daystring+'&endhour='+thishour+'&endminute=59&provider=SAO">'+ $
            '  VSO data for '+thishour+':00 to '+nexthour+':00  </a></h3>']
   ENDFOR


   tail=['<hr>', $
         '<address></address>', $
         '<!-- hhmts start --> <!-- hhmts end -->', $
         '</body> </html>']

   htmlfile=[head,body,tail]


   openw,lun,htmlfilename,/get_lun,error=err

   IF err NE 0 THEN BEGIN 
      openu,logfilelun,logfilename,/append
      printf,logfilelun,'Error creating HTML file '+htmlfilename
      close,logfilelun
   ENDIF

   printf,lun,htmlfile,format='(a)'

   close,lun
   free_lun,lun
 
ENDFOR

END





