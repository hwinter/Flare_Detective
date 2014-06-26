PRO xrt_dv_find_missing_pixels, start_time, $
                                end_time, $
                                xrtfiledir=xrtfiledir, $
                                missing_string=string, $
                                loud=loud

; =========================================================================
;		
;+
; PROJECT:
;       Solar-B / XRT
;
; NAME:
;
;       XRT_DV_FIND_MISSING_PIXELS
;
; CATEGORY:
;
;       XRT Data Verification utilities
;
; PURPOSE:
;
;       Print to the screen a list of XRT images with horizontal bands of
;       missing data in a given time interval. Reports the total number and
;       percentage of missing pixels (1 kpixel = 1024 pixels). 
;
; CALLING SEQUENCE:
;
;       XRT_DV_FIND_MISSING_PIXELS,start_time,end_time
;                                 [,xrtfiledir=xrtfiledir]
;                                 [,missing_string=missing_string]
;                                 [,/loud]
;
; INPUTS:
;
;       start_time: (string or double) start of the time
;                   interval that is checked for incomplete images. Can be in 
;                   any format accepeted by ANYTIM.
;       end_time:   (string or double) end of the time
;                   interval that is checked for incomplete images. Can be in 
;                   any format accepeted by ANYTIM.
;
; OPTIONAL INPUTS:
;
;       xrtfiledir: (string) Root of the directory trees where XRT images reside. The default
;                   is '/archive/hinode/xrt/QLraw'. Direcotry structure is assumed to
;                   be in the form xrtfiledir+'yyyy/mm/dd/Hxx00/'
;       loud:       (0 or 1) If set, debugging output is shown.
;
;
; OPTIONAL OUTPUT:
;       missing_string: a copy of the terminal output in form of an array of
;                      strings (1 per line)
;
; EXAMPLE:
;
;       find all incomplete images between 2008/10/03 10:00 UT and 2008/10/04 10:00 UT
;       xrt_dv_find_missing_pixels,'03-OCT-2008 10:00','04-OCT-2008 10:00'
;
; COMMON BLOCKS:
;
;       none
;
; PROCEDURE
;       This routine looks at the content of XRT images and counts the pixel
;       with value of 0 (pixel with real data always have values larger than
;       ~ 40).
;
; NOTE:
; Warning: since this program reads in the FITS data, it will be slow for
;          time intervals spanning more than about a day or so.
;
;
; MODIFICATION HISTORY:
; 
; 
progver='v2008.Oct.08'  ;--- P. Grigis written, uses code from xrt_dv_find_missing_imgs
progver='v2008.Oct.10'  ;--- PG fixed bug in computation of number of hours in the interval
progver='v2008.Oct.27'  ;--- PG changed header to reflect XRT standard format
;
;
;-
; =========================================================================



  ; define archive directory
  dir = fcheck(xrtfiledir,'/archive/hinode/xrt/QLraw')

  ; OS dependent path separator
  ps=path_sep()

  ;convert inputs to anytim format: external representation
  s_time = anytim(start_time)
  e_time = anytim(  end_time)

  ;compute how many hours and days there are in the interval
  n_hours=ceil((e_time-s_time)/3600.+1)

  ;initialize file list
  allfiles=''

  ;hunt for files in the archive tree
  FOR i=0L,n_hours-1 DO BEGIN 

     ;this hour
     thistime=anytim(s_time+3600.*i,/ex)

     ;create dir path
     thisdir=dir+ps+strtrim(thistime[6],2)+ps+string(thistime[5],format='(i2.2)') $
             +ps+string(thistime[4],format='(i2.2)')+ps+'H'+string(thistime[0],format='(i2.2)')+'00'
 
     IF keyword_set(loud) THEN print,thisdir

     ;find all FITS files in the dir
     thisfiles = find_files('*.fits', thisdir)

     ;if some files are found, add them to the list
     IF thisfiles[0] NE '' THEN allfiles=[allfiles,thisfiles]

  ENDFOR

  ;no files found in the interval? done
  IF n_elements(allfiles) EQ 1 THEN BEGIN 
     string='No XRT images in '+anytim(start_time,/vms)+' to '+anytim(end_time,/vms)
     print,string
     RETURN 
  ENDIF

  ;at least two images, remove dummy empty string as first element
  allfiles=allfiles[1:*]

  ;output string
  string=''

  ;loops over individual images to conserve memory
  FOR i=0,n_elements(allfiles)-1 DO BEGIN 

     IF keyword_set(loud) THEN print,allfiles[i]

     read_xrt,allfiles[i],index,data,/quiet
     dummy=where(data EQ 0,count)

     IF count GT 0 THEN BEGIN 

        fillfactor=double(count)/(index.naxis1*index.naxis2)
        thisstring='Image EC_ID '+string(index.ec_id,format='(i6)')+', taken at '+anytim(index.date_obs,/vms)+' has '+string(round(count/1024.),format='(i4)')+' kpixel ('+string(fillfactor*100,format='(f5.1)')+'%) missing'
        print,thisstring
        string=[string,thisstring]

     ENDIF

  ENDFOR

  IF n_elements(string) GT 1 THEN string=string[1:*]

  RETURN

END
     
