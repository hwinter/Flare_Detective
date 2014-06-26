;+
;
; NAME:
;        getgoestemp
;
; PURPOSE: 
;
;        return the temperature and emission measure from GOES data
;        (see documentation to goes_tem.pro by R. Schwartz)
;
; CALLING SEQUENCE:
;
;        out=getgoestemp(time_intv)
; 
; INPUTS:
;
;        time_intv: time interval
;
; KEYWORDS:
;        /goes8,/goes10, etc. : goes satellite to use
;                
; OUTPUT:
;        out: structure with T: temperature EM: Emission Measure
;
; CALLS:
;       goes_tem, goes_ltc object
;
; VERSION:
;       
;       18-SEP-2003 written
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;-

FUNCTION getgoestemp,time_intv,_extra=_extra

time_intv=anytim(time_intv)

goesobj=obj_new('goes_ltc')

IF keyword_set(_extra) THEN BEGIN
    goesobj->set,tstart=anytim(min(time_intv),/atime) $
                ,tend=anytim(max(time_intv),/atime),_extra=_extra 
ENDIF $
ELSE $
    goesobj->set,tstart=anytim(min(time_intv),/atime) $
                ,tend=anytim(max(time_intv),/atime),/goes8 
  

goesobj->read

d=goesobj->getdata(low=low,high=high,time=time,utbase=utbase)

IF NOT exist(utbase) THEN RETURN,-1

time=anytim(utbase)+time

IF keyword_set(_extra) THEN $
    goes_tem,low,high,temp,em,_extra=_extra $
ELSE $
    goes_tem,low,high,temp,em,/goes8

RETURN,{temp:temp,em:em,time:time}

END












