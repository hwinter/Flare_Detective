;
; Qucik script to monitor fron end temperatures....
;


PRO xrt_hk_frontmonitor3,time=intime,hkfiledir=hkfiledir,hk_outimdir=hk_outimdir

;Two columns ASCII files with HK values lives in subdirs of
hkfiledir=fcheck(hkfiledir,'/data/solarb/XRT/hk_cron/')

;Images generated by this program are stored in subdirs of
hk_outimdir=fcheck(hk_outimdir,'~/www/xrtmon/')

;Plots runs until this time. Default is now in UT.
time=fcheck(intime,anytim(systime(1,/utc))+anytim('01-JAN-1970'))

dtime=10.*24.*3600.                                

;reads in 10 days of tmp11

print,'Reading TMP 11'
hkdata11=xrt_hk_getdata('TMP11C',time-dtime,time,hkfiledir=hkfiledir)
;reads in 10 days of tmp12
print,'Reading TMP 12'
hkdata12=xrt_hk_getdata('TMP12C',time-dtime,time,hkfiledir=hkfiledir)

oneyear=365.25*24.0*3600.0

print,'Reading TMP 11'
hkdata11old=xrt_hk_getdata('TMP11C',time-dtime-oneyear,time+dtime-oneyear,hkfiledir=hkfiledir)
;reads in 10 days of tmp12
print,'Reading TMP 12'
hkdata12old=xrt_hk_getdata('TMP12C',time-dtime-oneyear,time+dtime-oneyear,hkfiledir=hkfiledir)

IF size(hkdata11old,/tname) NE 'STRUCT' OR  size(hkdata11old,/tname) NE 'STRUCT' THEN BEGIN 
   print,'There was some problem in retrieving HK data - aborting'
   RETURN
ENDIF


timerange=time+[-dtime,+dtime]
t0=timerange[0]

midtime=(timerange[0]+timerange[1])*0.5

;limit=47.1
limit=49.0

linecolors

time11=hkdata11.time
temp11=hkdata11.value
time12=hkdata12.time
temp12=hkdata12.value

time11old=hkdata11old.time
temp11old=hkdata11old.value
time12old=hkdata12old.time
temp12old=hkdata12old.value

;expand values to account for missing data
;gaps longer than 30 seconds are filled with NANs
;therefore plots look nicer
xrt_hk_fillgaps,time11,temp11,gap=20.0,xout=x11,yout=y11
xrt_hk_fillgaps,time12,temp12,gap=20.0,xout=x12,yout=y12

xrt_hk_fillgaps,time11old,temp11old,gap=20.0,xout=x11old,yout=y11old
xrt_hk_fillgaps,time12old,temp12old,gap=20.0,xout=x12old,yout=y12old

;yrange=[45,48]
yrange=[(min([temp11,temp12])>0)-3,1+max([temp11,temp12])<80]

utplot,midtime-t0,0,t0,timerange=timerange,yrange=yrange,/xstyle,/ystyle,title='TMP11' $
      ,labelpar=[0,14],xmargin=[20,2],xtitle='Plot created on '+anytim(time,/vms)+' UT',_extra=_extra

oplot,!X.crange,[limit,limit],color=2

outplot,x11-t0,y11,t0
outplot,x11old+oneyear-t0,y11old,t0,color=12


filename=hk_outimdir+'tmp11_newandold.png'

tvlct,r,g,b,/get
write_png,filename,tvrd(),r,g,b


utplot,midtime-t0,0,t0,timerange=timerange,yrange=yrange,/xstyle,/ystyle,title='TMP12' $
      ,labelpar=[0,14],xmargin=[20,2],xtitle='Plot created on '+anytim(time,/vms)+' UT',_extra=_extra

oplot,!X.crange,[limit,limit],color=2

outplot,x12-t0,y12,t0
outplot,x12old+oneyear-t0,y12old,t0,color=12

filename=hk_outimdir+'tmp12_newandold.png'
tvlct,r,g,b,/get
write_png,filename,tvrd(),r,g,b




END 



