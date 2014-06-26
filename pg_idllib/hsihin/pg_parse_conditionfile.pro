;+
; NAME:
;
;   pg_parse_conditionfile
;
; PURPOSE:
;
;   read a text files with TAGS to use as conditions for RHESSI flare selection
;
; CATEGORY:
;
;   RHESSI util
;
; CALLING SEQUENCE:
;
;   condlist=pg_parse_conditionfile(filename)
;
; INPUTS:
;
;   filename: path to a valid file name
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
; an IDL list with the tag names and values
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
;   12-JAN-2007 written PG
;
;-

;.comp pg_parse_conditionfile

function pg_parse_conditionfile,filename

     if not file_exist(filename) then begin
         print,'Invalid file name!'
         return,-1
     endif

     openr,lun,filename,/get_lun
     row=''

     while not eof(lun) do begin 
         readf,lun,row

         firstchar=strmid(row,0,1)

         ;print,'first'+firstchar+'char'

         if ~(firstchar EQ ';' OR firstchar EQ ' ' OR firstchar EQ '') then begin
             rowelements=strsplit(row,' ',/extract)
             tagname=rowelements[0]
             value=rowelements[1]


             case tagname of 
                 'MIN_GOES_FLUX': value=double(value)
                 'MAX_GOES_FLUX': value=double(value)
                 'START_DATE' : value=anytim(value)
                 'END_DATE' : begin 
                     if strupcase(value) eq 'TODAY' then begin
                         value=systime(1)+anytim('01-jan-1970')
                     endif $
                     else value=anytim(value)
                 end
             endcase

             resstruct=add_tag(resstruct,value,tagname)

             
         endif

 
         ;print,row


     endwhile

     close,lun
     free_lun,lun

     return,resstruct

end
