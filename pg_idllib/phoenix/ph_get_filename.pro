;+
; NAME:
;       ph_get_filename
;
; PURPOSE: 
;       returns the phoenix full path filename corrseponding to an
;       input time
;
; CALLING SEQUENCE:
;       file=ph_get_filename(time)
;
; INPUTS:
;       time: input time, in any format accepted by anyitim
;
;
; HISTORY:
;       17-DEC-2002 written
;
; AUTHOR:
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;-

FUNCTION ph_get_filename,time,polarisation=polarisation

IF keyword_set(polarisation) THEN pol='p' ELSE pol='i'

t=anytim(time[0],/ex)

;dir='/global/helene/local/rag/observations/'
;dir='/global/pandora/data3/rag/phoenix-2/observations/'
dir='/ftp/pub/hedc/fs/data3/rag/observations/'
 
dir=dir+strtrim(t[6],2)+'/'+smallint2str(t[5])+'/'+smallint2str(t[4])+'/'


;print,t 

nearestqrt='00'

IF t[1] GE 15 THEN nearestqrt='15'
IF t[1] GE 30 THEN nearestqrt='30'
IF t[1] GE 45 THEN nearestqrt='45'

IF (t[0] EQ 12) AND (nearestqrt EQ '00') THEN nearestqrt='05'

filename=dir+strtrim(t[6],2)+smallint2str(t[5])+smallint2str(t[4])+ $
         smallint2str(t[0])+nearestqrt+'00'+pol+'.fit'

IF findfile(filename) EQ '' THEN filename=filename+'.gz'
IF findfile(filename) EQ '' THEN filename=''

RETURN,filename

END
