;+
; NAME:
;
; pg_update_xrtqlook
;
; PURPOSE:
;
; Main program for updating the XRT quicklook on the web page
;
; CATEGORY:
;
; qlook util for XRT
;
; CALLING SEQUENCE:
;
; pg_update_xrtqlook
;
; INPUTS:
;
; NONE, inputs are passed through environmental variables, to allow batch operation
;       from scripts.
;
;      List of environmental variable used (boolean means "TRUE" or "FALSE"):
;           XRT_SNPV_UPDATE_NDAYS   : (number) days to update for
;           XRT_SNPV_GEN_PNG        : (boolean) switch generation of png files on/off
;           XRT_SNPV_GEN_HTML       : (boolean) switch generation of html daily files on/off
;           XRT_SNPV_ERRLOG         : (filename) error log file
;           XRT_SNPV_IMAGES_DIR     : (filename) directory for storing the png images
;           XRT_SNPV_HTML_DIR       : (filename) directory for storing the html daily files
;           XRT_SNPV_IMSIZE         : (string) image size: either "LARGE" or
;                                              "SMALL" (large is 1600x1200, small 1200x700)
;
;  
; OPTIONAL INPUTS:
;
;
;
; KEYWORD PARAMETERS:
;
;
; OUTPUTS:
;
; NONE, but files are generated in the directories $XRT_SNPV_IMAGES_DIR
;       and $XRT_SNPV_HTML_DIR
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
; $Id: xrt_snpv_update.pro 44 2008-01-11 14:33:04Z pgrigis $
;
; MODIFICATION HISTORY:
;
; 04-DEC-2007 PG written 
; 19-DEC-2007 PG finalized
; 
;-


PRO xrt_snpv_update

  ;find the current time
  thistime=anytim(!stime)

  ;name of the logfile
  xrt_snpv_errlog=get_logenv('XRT_SNPV_ERRLOG')

  ;default logfile is environment variable undefined
  IF xrt_snpv_errlog EQ '' THEN BEGIN 
     xrt_snpv_errlog='xrt_snpv_errlog.txt'
  ENDIF

  ;first opening of error log file
  openw,lun,xrt_snpv_errlog,/get_lun,error=err
  IF err NE 0 THEN BEGIN
     print,'Error opening file '+xrt_snpv_errlog
     RETURN
  ENDIF

  printf,lun,'The XRT quicklook update process has started on '+anytim(thistime,/vms)
  close,lun

  ;images base dir --> will put the files in a tree starting there 
  ;with usual structure: 2007/12/05 
  xrt_snpv_images_dir=get_logenv('XRT_SNPV_IMAGES_DIR')

  IF xrt_snpv_images_dir EQ '' THEN BEGIN 
     openu,lun,xrt_snpv_errlog,/append
     printf,lun,'$XRT_SNPV_IMAGES_DIR environment variable is missing. Aborting'
     close,lun
     free_lun,lun
     return
  ENDIF ELSE BEGIN 
     openu,lun,xrt_snpv_errlog,/append
     printf,lun,'$XRT_SNPV_IMAGES_DIR is set to "'+xrt_snpv_images_dir+'"'
     close,lun 
  ENDELSE

  ;location for the html files with the daily collection of images
  xrt_snpv_html_dir=get_logenv('XRT_SNPV_HTML_DIR')

  IF xrt_snpv_images_dir EQ '' THEN BEGIN 
     openu,lun,xrt_snpv_errlog,/append
     printf,lun,'$XRT_SNPV_HTML_DIR environment variable is missing. Aborting'
     close,lun
     free_lun,lun
     return
  ENDIF ELSE BEGIN 
     openu,lun,xrt_snpv_errlog,/append
     printf,lun,'$XRT_SNPV_HTML_DIR is set to "'+xrt_snpv_html_dir+'"'
     close,lun 
  ENDELSE

  ;check image size
  xrt_snpv_imsize=get_logenv('XRT_SNPV_IMSIZE')

  IF xrt_snpv_images_dir EQ '' THEN BEGIN 
     openu,lun,xrt_snpv_errlog,/append
     printf,lun,'$XRT_SNPV_IMSIZE environment variable is missing. Defaulting to LARGE images'
     close,lun
     xrt_snpv_imsize='LARGE'
     
  ENDIF ELSE BEGIN 
     openu,lun,xrt_snpv_errlog,/append
     printf,lun,'$XRT_SNPV_HTML_DIR is set to "'+xrt_snpv_imsize+'"'
     close,lun 
  ENDELSE


  ;check whether html or png files or both need to be generated
  
  xrt_snpv_gen_png =get_logenv('XRT_SNPV_GEN_PNG')
  xrt_snpv_gen_html=get_logenv('XRT_SNPV_GEN_HTML')

  IF xrt_snpv_gen_png EQ 'TRUE' THEN BEGIN      
     openu,lun,xrt_snpv_errlog,/append
     printf,lun,'The script will generate PNG snapview images.'
     close,lun 
  ENDIF
  IF xrt_snpv_gen_html EQ 'TRUE' THEN BEGIN      
     openu,lun,xrt_snpv_errlog,/append
     printf,lun,'The script will generate HTML snapview files.'
     close,lun 
  ENDIF

  ;check whether the normal or the quicklook catalog should be used
  
  xrt_use_qlook_catalog=(get_logenv('XRT_USE_QLOOK_CATALOG')) EQ 'TRUE'

  ;update snpv

  ;find out which interval to update


  xrt_snpv_update_ndays=get_logenv('XRT_SNPV_UPDATE_NDAYS')

  thistime=!stime

  IF xrt_snpv_update_ndays NE '' THEN BEGIN  
     ndays=fix(xrt_snpv_update_ndays)   
  ENDIF $
  ELSE BEGIN 
     ndays=10
  ENDELSE
  

  IF ndays EQ 0 THEN BEGIN 
     time_intv=[anytim('23-OCT-2006'),anytim(thistime,/date_only)]
  ENDIF $
  ELSE BEGIN 
     time_intv=anytim((anytim(thistime)-[86400.0*ndays,0.]),/date_only)
  ENDELSE

  ;will go and look for GOES data & RHESSI obssumm data if not found locally
  search_network,/enable


  ;generates PNG images
  IF xrt_snpv_gen_png EQ 'TRUE' THEN BEGIN        
     xrt_snpv_create_png,time_intv,xrt_snpv_images_dir,xrt_snpv_html_dir $
                        ,logfilelun=lun,logfilename=xrt_snpv_errlog $
                        ,xrt_use_qlook_catalog=xrt_use_qlook_catalog $
                        ,imsize=xrt_snpv_imsize 
     
     thistime=!stime

     openu,lun,xrt_snpv_errlog,/append  
     printf,lun,'PNG image generation finished at '+anytim(thistime,/vms)
     close,lun

  ENDIF


  ;generates HTML files
  IF xrt_snpv_gen_html EQ 'TRUE' THEN BEGIN        
     xrt_snpv_create_html,time_intv,xrt_snpv_images_dir,xrt_snpv_html_dir $
                    ,logfilelun=lun,logfilename=xrt_snpv_errlog $
                    ,xrt_use_qlook_catalog=xrt_use_qlook_catalog $
                    ,imsize=xrt_snpv_imsize 
     
     
     thistime=!stime

     openu,lun,xrt_snpv_errlog,/append  
     printf,lun,'HTML files generation finished at '+anytim(thistime,/vms)
     close,lun

  ENDIF

  
  free_lun,lun
 
END


