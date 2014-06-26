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
; NONE (inputs are passed through environmental variables, to allow batch operation
; from scripts)
;  
; OPTIONAL INPUTS:
;
;
;
; KEYWORD PARAMETERS:
;
;
;
; OUTPUTS:
;
; NONE, several file generated
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
; $Id: pg_update_xrtqlook.pro 27 2007-12-18 14:07:52Z pgrigis $
;
; MODIFICATION HISTORY:
;
; 04-DEC-2007 PG written 
; 
;-

;.comp pg_update_xrtqlook

PRO pg_update_xrtqlook

  ;find the current time
  thistime=anytim(!stime)

  ;name of the logfile
  xrt_qlook_errlog=get_logenv('XRT_QLOOK_ERRLOG')

  ;default logfile is environment variable undefined
  IF xrt_qlook_errlog EQ '' THEN BEGIN 
     xrt_qlook_errlog='xrt_qlook_errlog.txt'
  ENDIF

  openw,lun,xrt_qlook_errlog,/get_lun,error=err
  IF err NE 0 THEN BEGIN
     print,'Error opening file '+xrt_qlook_errlog
     RETURN
  ENDIF

  printf,lun,'The XRT quicklook update process has started on '+anytim(thistime,/vms)
  close,lun

  ;images base dir --> will put the files in a tree starting there 
  ;with usual structure: 2007/12/05 
  xrt_qlook_images_dir=get_logenv('XRT_QLOOK_IMAGES_DIR')

  IF xrt_qlook_images_dir EQ '' THEN BEGIN 
     openu,lun,xrt_qlook_errlog,/append
     printf,lun,'$XRT_QLOOK_IMAGES_DIR environment variable is missing. Aborting'
     close,lun
     free_lun,lun
     return
  ENDIF ELSE BEGIN 
     openu,lun,xrt_qlook_errlog,/append
     printf,lun,'$XRT_QLOOK_IMAGES_DIR is set to "'+xrt_qlook_images_dir+'"'
     close,lun 
  ENDELSE

  ;location for the html files with the daily collection of images
  xrt_qlook_html_dir=get_logenv('XRT_QLOOK_HTML_DIR')

  IF xrt_qlook_images_dir EQ '' THEN BEGIN 
     openu,lun,xrt_qlook_errlog,/append
     printf,lun,'$XRT_QLOOK_HTML_DIR environment variable is missing. Aborting'
     close,lun
     free_lun,lun
     return
  ENDIF ELSE BEGIN 
     openu,lun,xrt_qlook_errlog,/append
     printf,lun,'$XRT_QLOOK_HTML_DIR is set to "'+xrt_qlook_html_dir+'"'
     close,lun 
  ENDELSE


  ;check whether html or png files or both need to be generated
  
  xrt_snpv_gen_png =get_logenv('XRT_SNPV_GEN_PNG')
  xrt_snpv_gen_html=get_logenv('XRT_SNPV_GEN_HTML')

  IF xrt_snpv_gen_png EQ 'TRUE' THEN BEGIN      
     openu,lun,xrt_qlook_errlog,/append
     printf,lun,'The script will generate PNG snapview images.'
     close,lun 
  ENDIF
  IF xrt_snpv_gen_html EQ 'TRUE' THEN BEGIN      
     openu,lun,xrt_qlook_errlog,/append
     printf,lun,'The script will generate HTML snapview files.'
     close,lun 
  ENDIF

  ;check whether the normal or the quicklook catalog should be used
  
  xrt_use_qlook_catalog=(get_logenv('XRT_USE_QLOOK_CATALOG')) EQ 'TRUE'

  ;update qlook

  time_intv=anytim(['10-SEP-2007','01-DEC-2007'])
;  time_intv=anytim(['12-DEC-2007','18-DEC-2007'])
  search_network,/enable

  IF xrt_snpv_gen_png EQ 'TRUE' THEN BEGIN        
     xrt_snpv_create_png,time_intv,xrt_qlook_images_dir,xrt_qlook_html_dir $
                        ,logfilelun=lun,logfilename=xrt_qlook_errlog $
                        ,xrt_use_qlook_catalog=xrt_use_qlook_catalog
     
     thistime=!stime

     openu,lun,xrt_qlook_errlog,/append  
     printf,lun,'PNG image generation finished at '+anytim(thistime,/vms)
     close,lun

  ENDIF

  IF xrt_snpv_gen_html EQ 'TRUE' THEN BEGIN        
     xrt_snpv_create_html,time_intv,xrt_qlook_images_dir,xrt_qlook_html_dir $
                    ,logfilelun=lun,logfilename=xrt_qlook_errlog $
                    ,xrt_use_qlook_catalog=xrt_use_qlook_catalog
     
     
     thistime=!stime

     openu,lun,xrt_qlook_errlog,/append  
     printf,lun,'HTML files generation finished at '+anytim(thistime,/vms)
     close,lun

  ENDIF

  
  free_lun,lun
 
END


