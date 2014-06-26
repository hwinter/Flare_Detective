;+
; NAME:
;
;   xrt_hk_plot_1val
;
; PURPOSE:
;
;   Plot single housekeeping values
;
; CATEGORY:
;
;   XRT HK utils
;
; CALLING SEQUENCE:
;
;     xrt_hk_plot_1val,hkdata,time,/three,hk_outimdir=hk_outimdir
;
; INPUTS:
;
;
; OPTIONAL INPUTS:
;
;   hkdata:         a data structure such as the one produced by by xrt_hk_getdata
;   time:           housekeeping plots are generated for 7 days, 24 hours, 6 hours and 3
;                   hours before time. Default is now.
;   hk_outimdir:    root directory in which to save housekeeping plots. 
;                   Default: '/data/solarb/XRT/hk_pro/images/'
;   tagfile:        File with the list of all HK values files to read in.
;                   Deafult='/data/solarb/XRT/hk_pro/programs/keywords_kkr.txt'
;
; KEYWORD PARAMETERS:
;
;   /three,/twelve,/twentyfour: specify time span of plots
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
;   NONE 
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
;   Reads in the HK value and plots them.
;
; EXAMPLE:
;
;  
; AUTHOR
;
; Paolo C. Grigis  
; pgrigis@cfa.harvard.edu
;
; MODIFICATION HISTORY:
;
;   17-NOV-2008 written PG (based on a routine by P. Jibben)
;
;-

PRO xrt_hk_plot_1val,hkdata,time,dtime=dtime,verbose=verbose $
                   ,hk_outimdir=hk_outimdir,save=save,gap=gap,_extra=_extra





gap=fcheck(gap,20.0)

val=hkdata.value
tim=hkdata.time

min=min(val)
max=max(val)
d=(max-min)+0.1
t0=min(tim)
t1=max(tim)


;expand values to account for missing data
;gaps longer than 30 seconds are filled with NANs
;therefore plots look nicer

dtime=fcheck(dtime,24)

;do plot
trange=time+[-dtime*3600.0-300,300]
now=anytim(systime(1,/utc)+anytim('01-JAN-1970'),/vms)

IF (t1 LT trange[0] || t0 GT trange[1]) || n_elements(tim) LT 2 THEN BEGIN 
   utplot,trange-t0,[0,0],t0,timerange=trange,yrange=[min,max]+[-1,1],/xstyle $
         ,labelpar=[0,14],xtitle='Plot created on '+now+' UT',_extra=_extra,/nodata,title=hkdata.name
   xyouts,0.1,0.5,'NO DATA FOUND',charsize=7,/normal,charthick=4
ENDIF $
ELSE BEGIN 
   xrt_hk_fillgaps,tim,val,gap=gap,xout=x,yout=y

   utplot,x-t0,y,t0,timerange=trange,yrange=[min,max]+[-1,1]*0.02*d,/xstyle $
         ,labelpar=[0,14],xtitle='Plot created on '+now+' UT',_extra=_extra,title=hkdata.name
ENDELSE 

;outplot,x-t0,y,t0



IF keyword_set(save) THEN BEGIN 
   filename=hk_outimdir+hkdata.name+'_'+string(dtime,format='(I02)')+'hr.png'
   IF keyword_set(verbose) THEN print,'Saving '+filename
   tvlct,r,g,b,/get
   write_png,filename,tvrd(),r,g,b
ENDIF


END

