;+
; NAME:
;
; pg_nano_applyoperation
;
; PURPOSE:
;
; returns some data from an event that is saved on disk. Neede to work around
; memory limitations in 32 bit IDL on Macs.
;
; CATEGORY:
;
; nanoflares utility
;
; CALLING SEQUENCE:
;
; res=pg_nano_applyoperation(operation)
;
; INPUTS:
;
; operation: a valid IDL expression on data_prepped
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
; MODIFICATION HISTORY:
;
;-
FUNCTION pg_nano_applyoperation,operation,quiet=quiet,dimarr=dimarr

dimarr=fcheck(dimarr,1)

datadir='~/machd/nanoflaredata/'
jitcordat=datadir+'/registered/'

FOR thispart=0,3 DO BEGIN 
   
   IF NOT keyword_set(quiet) THEN print,'Part: '+smallint2str(thispart,strlen=1)

   restore,jitcordat+'ev1_part'+smallint2str(thispart,strlen=1)

   dummy=execute(operation)
   
   CASE dimarr OF 
      1    : IF thispart EQ 0 THEN output=result ELSE output=[output,result]
      2    : IF thispart EQ 0 THEN output=result ELSE output=[[output],[result]]
      3    : IF thispart EQ 0 THEN output=result ELSE output=[[[output]],[[result]]]
      ELSE : output=-1
   ENDCASE

ENDFOR

return,output

END


