;+
; NAME:
;      pg_write_cat2text.pro
;
; PURPOSE: 
;      write the event catalog as a text file
;
; INPUTS:
;      
;
; 
;  
; OUTPUTS:
;      none
;      
; KEYWORDS:
;      
;
; HISTORY:
;       
;     15-FEB-2005 written PG
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;       pgrigis@astro.phys.ethz.ch
;
;-


PRO pg_write_cat2text,catalog,filename

openw,unit,filename,/get_lun   

printf,unit,'NUMBER  STARTTIME              ENDTIME'

FOR i=0,n_elements(catalog)-1 DO BEGIN
   printf,unit,smallint2str(catalog[i].number,strlen=3),'    ' $
         ,anytim((*catalog[i].time_intv)[0],/vms,/truncate),'   ' $
         ,anytim((*catalog[i].time_intv)[1],/vms,/truncate)
ENDFOR

close,unit

END
