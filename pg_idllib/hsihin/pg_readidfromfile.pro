;+
; NAME:
;
;   pg_readidfromfile
;
; PURPOSE:
;
;   read flare ID from a text file
;
; CATEGORY:
;
;   RHESSI util
;
; CALLING SEQUENCE:
;
;   idlist=pg_readidfromfile(filename)
;
; INPUTS:
;
;   filename
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
;  list of ids (long int)
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
;   15-JAN-2007 written PG
;
;-

;.comp  pg_readidfromfile

FUNCTION pg_readidfromfile,filename

  IF ~file_exist(filename) THEN BEGIN 
     print,'Invalid filename'
     return,-1L
  ENDIF

  openr,lun,filename,/get_lun

  line=''

  idlist=-1

  WHILE NOT eof(lun) DO BEGIN 
     readf,lun,line

     rowelements=strsplit(line,' ',/extract)
     id=long(rowelements[0])
     dir=rowelements[1]

     idlist=[idlist,id]

  ENDWHILE

  idlist=idlist[1:n_elements(idlist)-1]

  close,lun
  free_lun,lun

  return,idlist

END
