PRO xrt_dv_find_missing_imgs, start_time, $
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
;       XRT_DV_FIND_MISSING_IMGS
;
; CATEGORY:
;
;       XRT Data Verification utilities
;
;
; PURPOSE:
;
;       Print to the screen a list of missing XRT images in a given time interval
;
;
; CALLING SEQUENCE:
;
;       XRT_DV_FIND_MISSING_IMGS,start_time,end_time 
;                               [,xrtfiledir=xrtfiledir]
;                               [,missing_string=missing_string]
;                               [,/loud]
;
; INPUTS:
;
;       start_time: (string or double) start of the time
;                   interval that is checked for missing images. Can be in 
;                   any format accepeted by ANYTIM.
;       end_time:   (string or double) end of the time
;                   interval that is checked for missing images. Can be in 
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
;       find all missing images between 2008/10/03 10:00 UT and 2008/10/04 10:00 UT
;       xrt_dv_find_missing_imgs,'03-OCT-2008 10:00','04-OCT-2008 10:00'
;
; COMMON BLOCKS:
;
; none
;
; PROCEDURE:
;
;     This routine looks at the exposure control ID field (EC_ID) of the FITS
;     file headers of XRT images to determine whether some IDs are missing
;     (indicating that images have been lost). Missing images are identified as
;     jumps in the sequence of EC_ID (i.e. if the EC_IDs are 2,3,5,6,9,10 it
;     will identify images 4,7,8 as being missing).
;
;
; KNOWN PROBLEMS:
;
; a) When the EC_ID field rolls over from 32767 to 0, reports (incorrectly) one
;   (or more) missing images with EC_ID 32768.
; b) This routine will probably be confused if it should happen that one frame is
;    split over more than two contiguous files. However, this situation does not
;    seem to ever happen (or at least is very rare).
; c) When a stop command (XRT_CTRL_MANU) is issued to XRT while is taking an
;    exposure, that images will be aborted and not stored. This program will
;    report such images as missing.
;
; NOTES:
;    Warning: since this program reads in the FITS file header, it will be slow for
;          time intervals spanning more than a few days, where a sizable number of
;          FITS header needs to be read in.
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
progver='v2008.Aug'     ;--- K. Reeves written
progver='v2008.Oct.08'  ;--- P. Grigis modified logic for finding files and for analyzing EC_IDs
                        ;    such that it also recognizes one frame split
                        ;    in two files. Also documented.
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

  ;compute how many hours there are in the interval
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

  ;only one image? cannot find holes!
  IF n_elements(allfiles) EQ 2 THEN BEGIN 
     string=['Only one XRT image in '+anytim(start_time,/vms)+' to '+anytim(end_time,/vms),$
             'Cannot ascertain presence of missing images. Try again with larger time interval.']
     print,string
     RETURN
  ENDIF


  ;at least two images, remove dummy empty string as first element
  allfiles=allfiles[1:*]

  IF keyword_set(loud) THEN print,transpose(allfiles)


  ; read in index structures
  read_xrt, allfiles, index

  ;compute the difference between successive IDs
  ecid_diff = shift(index.ec_id,-1) - index.ec_id
  ;remove meaningless difference between last and first element 
  ecid_diff = ecid_diff[0:n_elements(ecid_diff)-2]

  ;find out if there are problems at all
  ind=where(ecid_diff NE 1,count)

  ;in case all is fine, we're done
  IF count EQ 0 THEN BEGIN
     print, "No missing image" 
     RETURN
  ENDIF

  
  ;time bracket for missing images
  startimes=index[ind].date_obs
  endtimes=index[(ind+1)<(n_elements(index)-1)].date_obs

  ;this are the "split" images (i.e. two files for one frame)
  ind0=where(ecid_diff[ind] EQ 0,count0)

  ;two or more missing images
  ind2=where(ecid_diff[ind] GT 2,count2)

  ;basic output string for 1 missing images
  string='  1 image,  EC_ID: '+string(index[ind].ec_id+1,format='(i6)')+'         missing between ' $
        +anytim(startimes,/vms)+' and '+anytim(endtimes,/vms)

  ;correct string for >2 images missing
  IF count2 GT 0 THEN BEGIN 
     string[ind2]=string(ecid_diff[ind[ind2]]-1,format='(i3)')+' images, EC_ID: '+string(index[ind[ind2]].ec_id+1,format='(i6)')+' -' $
                  +string(index[ind[ind2]].ec_id+ecid_diff[ind[ind2]]-1,format='(i6)')+ $
                  ' missing between '+anytim(startimes[ind2],/vms)+' and '+anytim(endtimes[ind2],/vms)
  ENDIF


  ;correct string for "split" images
  IF count0 GT 0 THEN BEGIN 
     string[ind0]='  1 image,  EC_ID: '+string(index[ind[ind0]].ec_id,format='(i6)')+ $
                  ' is divided in two files '+anytim(startimes[ind0],/vms)+' '
  ENDIF

  print,string

  RETURN

END
     
