;+
; NAME:
;  
; CAL_SCRIPT
;
; PURPOSE:
;
; produces a small shell script to automatically convert callisto
; raw data to fits files in the right directories
;
; CATEGORY:
;
; RAPP utilities
;
; CALLING SEQUENCE:
;
; cal_raw2fits,date
;
; INPUTS:
;
; date: in format '1-DEC-2003' or any format accepted by anytim
;
; OPTIONAL INPUTS:
;
; none
;
; KEYWORD PARAMETERS:
;
; none
;
; OUTPUTS:
;
; none direct, creates a file called 'cal_script'
;
; OPTIONAL OUTPUTS:
;
; none
;
; COMMON BLOCKS:
;
; none
;
; SIDE EFFECTS:
;
; create a file called cal_script in the current diectory
;
; RESTRICTIONS:
;
; assumes rag dir is correctly mounted
;
; EXAMPLE:
; 
; cal_script,'31-NOV-2003'
;
; AUTHOR:
;
; Paolo C. Grigis, Institute for Astronomy, ETH Zurich
; pgrigis@astro.phys.ethz.ch
;
; MODIFICATION HISTORY:
; 
; 01-DEC-2003 written PG
; monstein
;
;-
PRO cal_script,date   

   
   ;;output script file name
   scriptfilename='cal_script'
 
   ;; this is the RAPP base directory
   ragdir='/ftp/pub/hedc/fs/data3/rag/'
   
   ;;convert date to 7 element representation (hh,mm,ss,msec,dd,mm,yyyy)
   date=anytim(date,/ex,error=error)   

   IF error NE 0 THEN $
     print,'Wrong date format! Processing aborted' $
   ELSE BEGIN

      year_string=strtrim(string(date[6]),2)
      month_string=strtrim(smallint2str(date[5]),2)
      day_string=strtrim(smallint2str(date[4]),2)

      ;;dir for the raw data
      rawdatadir=ragdir+'callisto/raw_archive/'+year_string+'/Zurich_sts/' + $
               month_string+'/'+day_string+'/'

      ;;dir for the calibrated data
      caldatadir=ragdir+'callisto/observations/'+year_string+'/'+ $
                 month_string+'/'+day_string+'/'


      ;;open file for output, get file handle "unit"
      openw,unit,scriptfilename,/get_lun

      ;;write command sequence to the file
      printf,unit,'cd '+rawdatadir
      printf,unit,'cal_to_fits *.raw'
      printf,unit,'rm 2*p.fit'
      printf,unit,'gzip *.*'

      ;; creates the directory only if it don't exist already
      IF NOT file_exist(caldatadir) THEN printf,unit,'mkdir '+caldatadir

      printf,unit,'mv *.fit.gz '+caldatadir
      
      ;;close and save file
      close,unit

      ;;change mode to executable

      file_chmod,scriptfilename,/u_execute
      
   ENDELSE

   RETURN

END
