;+
; NAME:
;      pg_plotospex_overview
;
; PURPOSE: 
;      plot summary information from a SPEX object
;
; CALLING SEQUENCE:
;     
;      pg_plotospex_overview,osp
;
; INPUTS:
;     
;      osp: SPEX object
; 
;  
; OUTPUTS:
;      
;      
; KEYWORDS:
;
; HISTORY:
;      
;      14-MAR-2004 written PG
;
;
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;       pgrigis@astro.phys.ethz.ch
;
;-


PRO pg_plotospex_overview,osp,eband=eband,tover=tover,mult=mult,thick=thick,_extra=_extra

eband=fcheck(eband,[3,25])
tover=fcheck(tover,100.)
mult=fcheck(mult,replicate(1d,n_elements(eband)))
thick=fcheck(thick,replicate(1d,n_elements(eband)))

speband=osp->get(/spex_ct_edges)
sptime=osp->get(/spex_ut_edges)
time=0.5*total(sptime,1)

data=osp->getdata(class='spex_data',spex_units='flux')

neb=n_elements(eband)
nt=n_elements(time)

flux=dblarr(neb-1,nt)

FOR i=0,neb-2 DO BEGIN 

   eind=where((speband[0,*] GE eband[i]) AND (speband[1,*] LE eband[i+1]),count)

   IF count EQ 0 THEN BEGIN
      print,'INVALID ENERGY BAND!'
      RETURN
   ENDIF

   flux[i,*]=total(data.data[eind,*],1)

ENDFOR


fit_times=osp->get(/spex_fit_time_interval)
timerange=[min(fit_times),max(fit_times)]+tover*[-1,1]

timeind=where(time GE timerange[0] AND time LE timerange[1],count)
IF count EQ 0 THEN BEGIN
      print,'INVALID TIME!'
      RETURN
ENDIF

maxdata=max(flux[*,timeind])
yrange=[0,maxdata]

utplot,time-time[0],flux[0,*]*mult[0],time[0],timerange=timerange $
      ,ytitle='counts s!U-1!N cm!U-2!N keV!U-1!N',yrange=yrange $
      ,xtitle=anytim(time[0],/date_only,/yohkoh),thick=thick[0] $
      ,_extra=_extra

FOR i=1,neb-2 DO BEGIN 
outplot,time-time[0],flux[i,*]*mult[i],time[0],thick=thick[1]
ENDFOR


FOR i=0,n_elements(fit_times[0,*])-1 DO BEGIN
   outplot,fit_times[0,i]*[1,1]-time[0],!y.crange,time[0]
   outplot,fit_times[1,i]*[1,1]-time[0],!y.crange,time[0]
ENDFOR


;SPEX_UT_EDGES   DOUBLE    Array[2, 1124]
;SPEX_CT_EDGES   FLOAT     Array[2, 47]

data=osp->getdata()


END



