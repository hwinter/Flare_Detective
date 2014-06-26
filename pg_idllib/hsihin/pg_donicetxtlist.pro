;+
; NAME:
;
;   pg_donicetxtlist
;
; PURPOSE:
;
;   read flare info from FITS file and write a nice text file with the events
;
; CATEGORY:
;
;   RHESSI util
;
; CALLING SEQUENCE:
;
;   pg_donicetxtlist,inputfile,outfile
;
; INPUTS:
;
;   inputfile: a FITS file with info on the events
;   outfile: filename for the output text file
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
;  
;    
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
;   Paolo Grigis ( pgrigis@astro.phys.ethz.ch )
;
; MODIFICATION HISTORY:
;
;   30-JAN-2007 written PG
;
;-

;.comp  pg_donicetxtlist

PRO pg_donicetxtlist,infile,outfile

  dir='~/hyd/hsiflaresforhinode/data/'

  infile=fcheck(infile,dir+'flarelist_done.fits')
  outfile=fcheck(outfile,dir+'flarelist_nice.txt')


  IF ~file_exist(infile) THEN BEGIN 
     print,'Invalid filename'
     return
  ENDIF

  openw,lun,outfile,/get_lun

  data1=mrdfits(infile,1,header1)

  sortind=sort(data1.start_time)

  printf,lun,'#  DATE     START    END      XPOS  YPOS  GOES'
  printf,lun,'#'

  FOR j=0,n_elements(data1)-1 DO BEGIN 

     i=sortind[j]
  
     date=anytim(data1[i].start_time,/date_only,/yoh)
     stime=anytim(data1[i].start_time,/time_only,/external)
     etime=anytim(data1[i].end_time,/time_only,/external)
     IF (stime[0]*3600.+stime[1]*60.+stime[2]) GT (etime[0]*3600.+etime[1]*60.+etime[2]) THEN BEGIN
        ;stop
        etime[0]=etime[0]+24
     ENDIF

     xpos=string(round(data1[i].xpos),format='(i5)')
     ypos=string(round(data1[i].ypos),format='(i5)')

     IF data1[i].xpos^2+data1[i].ypos^2 EQ 0 THEN BEGIN 
        xpos='-----'
        ypos='-----'
     ENDIF

     gc=togoes(data1[i].goes_class)
   

     printf,lun,date+' '+smallint2str(stime[0],strlen=2)+':' $
                 +smallint2str(stime[1],strlen=2)+':' $
                 +smallint2str(stime[2],strlen=2)+' ' $
                 +smallint2str(etime[0],strlen=2)+':' $
                 +smallint2str(etime[1],strlen=2)+':' $
                 +smallint2str(etime[2],strlen=2)+'  ' $
                 +xpos+' '+ypos+'  '+gc

  ENDFOR


  close,lun
  free_lun,lun


END
