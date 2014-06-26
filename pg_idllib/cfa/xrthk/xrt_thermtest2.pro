;
; Quick script to monitor temperatures....
; 25-OCT-2009 modified to plot all temps


PRO xrt_thermtest2,hkfiledir=hkfiledir,hk_outimdir=hk_outimdir

;Two columns ASCII files with HK values lives in subdirs of
hkfiledir=fcheck(hkfiledir,'/data/solarb/XRT/hk_cron/')

;Images generated by this program are stored in subdirs of
hk_outimdir=fcheck(hk_outimdir,'~/www/xrtmon/')

;Plots runs until this time. Default is now in UT.
timenow=fcheck(intime,anytim(systime(1,/utc))+anytim('01-JAN-1970'))

dtime=3600.                                

t0=anytim('22-OCT-2009 00:00')
t1=timenow+dtime
;t1='24-OCT-2009 00:00'

!p.charsize=1.6

templist=['TMP01C','TMP02C','TMP03C','TMP04C','TMP05C', $
          'TMP06C','TMP07C','TMP08C','TMP09C','TMP10C', $
          'TMP11C','TMP12C','TMP13C','TMP14C','TMP15C', $
          'TMP16C','TMP17C','TMP18C','TMP19C','TMP20C', $
          'TMP21C','TMP22C','TMP23C','TMP00C']

for i=0,n_elements(templist)-1 do begin 

   print,'Now processing Temperature: '+templist[i]

   filename=hk_outimdir+templist[i]+'.png'

   hkdata=xrt_hk_getdata(templist[i],t0,t1) 
   time=hkdata.time
   temp=hkdata.value
   xrt_hk_fillgaps,time,temp,gap=20.0,xout=x,yout=y
   utplot,x-x[0],y,x[0],title=hkdata.name+' last updated: (UT)'+anytim(timenow,/ccsds),yrange=[min(y)-1,max(y)+1],/ystyle,/xstyle,timerange=[t0,t1]

   tvlct,r,g,b,/get
   write_png,filename,tvrd(),r,g,b


endfor





END 


