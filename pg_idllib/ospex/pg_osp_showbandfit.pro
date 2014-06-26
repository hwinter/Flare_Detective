;+
; NAME:
;      pg_osp_showbandfit
;
; PURPOSE: 
;      create a new SPEX object, initialize the srm and sp files, sets
;      energy bands, fit intervals and make a nice plot of the chosen
;      settings (-> no background subtraction yet). The fit intervals
;      are centered around the maximum count rate in a band
;
; CALLING SEQUENCE:
;      pg_osp_showbandfit,basinfostr,event=event [,energy_band=energy_band
;         ,n_intv=n_intv,osp=osp,deltime=deltime,maxbandind=maxbandind]
;
; INPUTS:
;      basinfostr: structure with the relevant information about the events
;      event: string for the event or event number
;      energy_band
;      n_intv: number of fit intervals
;      osp: output spex object
;      deltime: fit interval duration
;      maxbandind: index of band to be checked for maximum
;      input_intv_duration: duration of time interval to be scanned
;         for maximum  around the average 
;
; KEYWORDS:
;        
;
; OUTPUT:
;      
;       
;
; COMMENT:
;      
;
; EXAMPLE   
;  
;       pg_osp_showbandfit,basinfostr,spsrmfiledir,event=1
;
; VERSION:
;       
;       07-OCT-2004 written PG
;
; AUTHOR:
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;       pgrigis@astro.phys.ethz.ch
;-

PRO pg_osp_showbandfit,basinfostr,spsrmfiledir,event=event $
       ,energy_band=energy_band,n_intv=n_intv,osp=osp,deltime=deltime $
       ,maxbandind=maxbandind,input_intv_duration=input_intv_duration $
       ,plot_duration=plot_duration

IF size(osp,/type) EQ 11 THEN BEGIN
   obj_destroy,osp
ENDIF

event=fcheck(event,0)
energy_band=fcheck(energy_band,[3,8,15,25,50])
n_intv=fcheck(n_intv,3)
deltime=fcheck(deltime,60.)
maxbandind=fcheck(maxbandind,0)
input_intv_duration=fcheck(input_intv_duration,n_intv*deltime)
plot_duration=fcheck(plot_duration,20.*60)

IF (NOT exist(basinfostr)) OR (NOT exist(spsrmfiledir)) THEN BEGIN
   print,'Please input a basinfo structure and a directory for the ' + $
         'sp & srm files'
   RETURN
ENDIF


IF size(event,/type) EQ 7 THEN  BEGIN 
   evind=where(basinfostr.evlabel EQ event,count)
   IF count NE 1 THEN BEGIN
      print,'NO UNIQUE EVENT '+event+ ' FOUND!'
      RETURN
   ENDIF
ENDIF ELSE $
   evind=event

evavgtime=basinfostr[evind].avgtime
evtime=time2file(evavgtime)
input_intv=evavgtime+0.5*input_intv_duration*[-1,1]

spfile=spsrmfiledir+'sp_'+evtime+'.fits'
srmfile=spsrmfiledir+'srm_'+evtime+'.fits'

osp=ospex(/no_gui)

osp->set,spex_specfile=spfile
osp->set,spex_drmfile=srmfile
osp->set,spex_eband=get_edges(energy_band,/edges_2)

dummy=osp->getdata(class_name='spex_data',/force)

pg_osp_setfitintv,osp,nintv=n_intv,this_band=maxbandind,tintv=deltime $
                    ,input_intv=input_intv

dummy=osp->getdata(class_name='spex_data',/force)


;osp->set,spex_bk_sep=1
;osp->set,spex_bk_eband=get_edges(energy_bands,/edges_2)

;deltat=10.*60.


nplots=n_elements(energy_band)-1
timerange=evavgtime+0.5*plot_duration*[-1,1]
title='COUNT FLUX FOR EVENT '+basinfostr[evind].evlabel

sfti=osp->get(/spex_fit_time_interval)

oldp=!P
!P.multi=[0,1,nplots]
FOR i=0,nplots-1 DO BEGIN
   osp->plot_time,/no_plotman,/data,this_band=i,/xstyle $
      ,timerange=timerange,charsize=1.75,spex_units='flux' $
      ,psym=0,ylog=0
   FOR j=0,n_elements(sfti)-1 DO BEGIN 
       outplot,sfti[j]*[1,1]-getutbase(),!y.crange,getutbase(),linestyle=2
   ENDFOR
ENDFOR

!P=oldp

RETURN

END
