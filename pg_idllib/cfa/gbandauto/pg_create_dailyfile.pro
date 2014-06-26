;+
; NAME:
;
; pg_create_dailyfile
;
; PURPOSE:
;
; create a g-band IDL weekly save file, given an input time interval
;
; CATEGORY:
;
; gband datraproduct automatic creation
;
; CALLING SEQUENCE:
; 
; pg_create_dailyfile,time_intv
;
; INPUTS:
;
; tim_intv: a 2 element array in anytim compatible format;
;           The file is created for that time.
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

PRO pg_create_dailyfile,time_intv,datadir=datadir

datadir=fcheck(datadir,'~/machd/gbandauto/')


startime=anytim(time_intv[0],/date_only)
endtime=anytim(anytim(time_intv[1])+24.*3600,/date_only)
ndays=round((endtime-startime)/(24.*3600.))

FOR i=0,ndays-1 DO BEGIN

   today=startime+24.*3600*i
   thisyear=(anytim(today,/ex))[6]
   time_intv=today+[0,24.*3600.-0.01]

   print,'Now doing : '+anytim(today,/vms)

   ;ptim,time_intv

   fnb='gband_day_'+strtrim(thisyear,2)+'_'+smallint2str(doy(today),strlen=3)
    
   ;print,fnb
   pg_create_gband_savefile,time_intv,filenamebase=fnb

ENDFOR





END

