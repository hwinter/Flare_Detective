;+
; NAME:
;
; pg_create_weeklyfile
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
; pg_create_weeklyfile,time_intv
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

PRO pg_create_weeklyfile,time_intv,datadir=datadir

datadir=fcheck(datadir,'~/machd/gbandauto/')


startime=anytim(time_intv[0],/ex)
startdoy=doy(time_intv[0])
endtime=anytim(time_intv[1],/ex)
enddoy=doy(time_intv[1])

startweek=((startdoy-1)>0)/7
endweek=(enddoy-1)/7

startyear=startime[6]
endyear=endtime[6]
deltay=endyear-startyear
thisyear=startyear

IF deltay EQ 0 THEN BEGIN 
   FOR i=startweek,endweek DO BEGIN 
      this_time_intv=[anytim(doytodate(thisyear,i*7+1)), $
                     (anytim(doytodate(thisyear,(i+1)*7+1))-0.1)<(anytim(doytodate(thisyear+1,1))-0.1)]

      fnb='gband_wk_'+strtrim(thisyear,2)+'_'+smallint2str(i,strlen=2)
      ;stop
      pg_create_gband_savefile,this_time_intv,filenamebase=fnb
      ;print,fnb

   ENDFOR
   
ENDIF ELSE BEGIN 
   FOR thisyear=startyear,endyear DO BEGIN 
      IF thisyear LT endyear THEN thisendweek=52 ELSE thisendweek=endweek
      IF thisyear GT startyear THEN thisstartweek=0 ELSE thisstartweek=startweek
      print,thisstartweek,thisendweek
      FOR i=thisstartweek,thisendweek DO BEGIN 
         this_time_intv=[anytim(doytodate(thisyear,i*7+1)), $
                         (anytim(doytodate(thisyear,(i+1)*7+1))-0.1)<(anytim(doytodate(thisyear+1,1))-0.1)]

         fnb='gband_wk_'+strtrim(thisyear,2)+'_'+smallint2str(i,strlen=2)
         pg_create_gband_savefile,this_time_intv,filenamebase=fnb
         ;print,fnb
         
      ENDFOR
   ENDFOR
ENDELSE


END

