;+
; NAME:
;      pg_plotospex_timev
;
; PURPOSE: 
;      plot the time evolution in different energy bands with
;      background and fit time interval for a SPEX object
;
; CALLING SEQUENCE:
;     
;      pg_plotospex_timev,osp
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
;      16-JUN-2005 written PG, based on pg_plotopsex_overview
;      06-JUL-2005 added /stackplot and stackmulti keyword PG
;
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;       pgrigis@astro.phys.ethz.ch
;
;-


PRO pg_plotospex_timev,osp,tover=tover,bcolor=bcolor,stackplot=stackplot,ylog=ylog $
                      ,stackmulti=stackmulti,addtitle=addtitle,mytitle=mytitle $
                      ,blinestyle=blinestyle,_extra=_extra    

;,mult=mult,thick=thick,_extra=_extra
;eband=fcheck(eband,[3,25])

IF n_elements(tover EQ 1) THEN tover=[-tover,tover]
tover=fcheck(tover,[-100.,100.])

;mult=fcheck(mult,replicate(1d,n_elements(eband)))
;thick=fcheck(thick,replicate(1d,n_elements(eband)))



ytitle='counts s!E-1!N cm!E-2!N kev!E-1!N '
;title=fcheck(title,' ')
addtitle=fcheck(addtitle,'')
bcolor=fcheck(bcolor,12)
blinestyle=fcheck(blinestyle,0)

eband=    osp->get(/spex_eband)
fit_times=osp->get(/spex_fit_time_interval)
speband=  osp->get(/spex_ct_edges)
sptime=   osp->get(/spex_ut_edges)

data= osp->getdata(class='spex_data',spex_units='flux')
bdata=osp->getdata(class='spex_bk'  ,spex_units='flux')
;'FLUX' means: counts s^-1 cm ^-2 keV^-1

;stop

time=0.5*total(sptime,1)
;time_intv=[min(time),max(time)]
timerange=[min(fit_times),max(fit_times)]+tover
time_intv=timerange

neb=n_elements(eband)/2
nt=n_elements(time)

stackmulti=fcheck(stackmulti,replicate(1.,neb))

dflux=dblarr(neb,nt)
bflux=dblarr(neb,nt)

oldp=!P

IF NOT keyword_set(stackplot) THEN BEGIN 
   !P.multi=[0,1,neb]
ENDIF


FOR i=0,neb-1 DO BEGIN 


   eind=where((speband[0,*] GE eband[0,i]) AND (speband[1,*] LE eband[1,i]),count)

   IF count EQ 0 THEN BEGIN
      print,'INVALID ENERGY BAND!'
      RETURN
   ENDIF

   range=eband[1,i]-eband[0,i]

   IF keyword_set(mytitle) THEN title=mytitle ELSE $
     title=addtitle+'Energy band: '+strtrim(string(eband[0,i]),2)+ $
                    '-'+strtrim(string(eband[1,i]),2)+' keV'

   dflux[i,*]=total(data.data[eind,*],1)/range
   bflux[i,*]=total(bdata.data[eind,*],1)/range

   IF keyword_set(stackplot) AND i NE 0 THEN BEGIN 
      outplot,time-time[0],dflux[i,*]*stackmulti[i],time[0],_extra=_extra
      outplot,time-time[0],bflux[i,*]*stackmulti[i],time[0],color=bcolor,linestyle=blinestyle
   ENDIF ELSE BEGIN 
      utplot,time-time[0],dflux[i,*]*stackmulti[i],time[0],timerange=time_intv,/xstyle,_extra=_extra $
                         ,ytitle=ytitle,title=title,ylog=ylog
      outplot,time-time[0],bflux[i,*]*stackmulti[i],time[0],color=bcolor,linestyle=blinestyle

      ycrange=keyword_set(ylog) ?  10^!y.crange : !y.crange

   ENDELSE


   timeind=where(time GE timerange[0] AND time LE timerange[1],count)
   IF count EQ 0 THEN BEGIN
      print,'INVALID TIME!'
      RETURN
   ENDIF


 
   FOR j=0,n_elements(fit_times[0,*])-1 DO BEGIN
      outplot,fit_times[0,j]*[1,1]-time[0],ycrange,time[0]
      outplot,fit_times[1,j]*[1,1]-time[0],ycrange,time[0]
   ENDFOR



ENDFOR

END



