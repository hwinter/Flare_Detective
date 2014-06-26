;+
; NAME:
;
; pg_plotfluxgamma
;
; PURPOSE:
;
; plots flux and gamma time evolution for flares
;
; CATEGORY:
;
; shs project utils
;
; CALLING SEQUENCE:
;
; pg_plotfluxgamma,spst [,fluxrange=fluxrange,sprange=sprange,...]
;
; INPUTS:
;
; spst: spectrum structure
;
; OPTIONAL INPUTS:
;
; timerange: time range for the plot (default: whole time interval +5%
; pastward and futureward)
; fluxrange: range for the flux (default: [0.01,10])
; sprange:   range for the spectral index (deafult: [8.5,2.75])
; fluxthick: line thickness for the flux (default: 2)
; spthick: line thickness for the spectral index (default: 1)
;
; KEYWORD PARAMETERS:
;
; fluxstyle: if set, exact y axis is used
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
; AUTHOR:
; Paolo Grigis, Institute of Astronomy, ETH Zurich
; pgrigis@astro.phys.ethz.ch
;
; MODIFICATION HISTORY:
;
; 31-MAR-2004 written P.G.
; 02-APR-2004 correceted a timerange bug
; 18-MAY-2004 added shiftright keyword
;-


PRO pg_plotfluxgamma,spst,fluxrange=fluxrange,sprange=sprange $
                    ,fluxthick=fluxthick,spthick=spthick,timerange=timerange $
                    ,fluxstyle=fluxstyle,charsize=charsize $
                    ,fluxtitle=fluxtitle,spindextitle=spindextitle $
                    ,shiftright=shiftright,_extra=_extra
   

   fluxrange=fcheck(fluxrange,[0.01,10])
   sprange=fcheck(sprange,[8.5,2.75])
   fluxthick=fcheck(fluxthick,2)
   spthick=fcheck(spthick,1)
   charsize=fcheck(charsize,1)

   shiftright=fcheck(shiftright,0)

   fluxstyle=keyword_set(fluxstyle)
   
   fluxtitle=fcheck(fluxtitle,'Non-thermal flux at 35 keV (F!D35!N)')
   spindextitle=fcheck(spindextitle,'Photon spectral index (!4c!3)')

   ;;get the spectral index and flux for the whole flare
   tagname='APAR_ARR'
   apararr=pg_getptrstrtag(ptr_new(spst),tagname,/transpose)
   spindex=reform(pg_apar2physpar(apararr,/spindex))
   flux=pg_apar2physpar(apararr,eref=35.)
   temp=pg_apar2physpar(apararr,/temp)
   em=pg_apar2physpar(apararr,/em)

;      ;get and check errors
;      tagname='APAR_SIGMA'
;      aparsig=pg_getptrstrtag(spst,tagname,/transpose)
;      espindex=reform(pg_apar2physpar(apararr,apar_sig=aparsig,/errspindex))
;      eflux=pg_apar2physpar(apararr,apar_sig=aparsig,eref=35.)

   ;;get the time
   tagname='XSELECT'
   xsel=pg_getptrstrtag(ptr_new(spst),tagname)
   time=anytim((spst).date)+0.5*total(xsel,1)

   dt=time[n_elements(time)-1]-time[0]       
   trange=[time[0]-0.05*dt,time[0]+1.05*dt]       
   timerange=fcheck(timerange,trange)
   
   ;;plot flux, no right y axis
   utplot,time-time[0],flux,time[0],/ylog,ystyle=8+fluxstyle,xstyle=1 $
         ,timerange=timerange $
         ,xtitle=anytim(time[0],/date_only,/vms) $
         ,yrange=fluxrange $
         ,ytitle=fluxtitle $
         ,charsize=charsize,thick=fluxthick,_extra=_extra
   
   ;;plot right y axis, save coordinates
   axis,!X.crange[1]-shiftright*(!x.crange[1]-!x.crange[0]),/save,/ylog $
        ,yrange=sprange,yaxis=1,/ystyle $
        ,ytickv=[1,2,3,4,5,6,7,8,9],yticks=8 $
        ,ytitle=spindextitle,charsize=charsize
   ;;overplot of psectral index
   outplot,time-time[0],spindex,time[0],thick=spthick


END
