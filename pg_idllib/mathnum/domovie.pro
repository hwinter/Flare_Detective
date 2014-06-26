;
;do movie etc...
;


;define working directory 
dir='~/work/ttd/movdata/res/'

dopreview=0


clmblog=18.                    ;coulomb log
eref=510.99892d                ;mc^2 in keV
steps_per_decade=30            ;number of grid points in a decade of energy
minen=-18                      ;log_10 of the minimum energy in problem, in this case 10E-8 mc^2
maxen=10d                      ;log_10 of the maximum energy in problem, in this case 10E1  mc^2
collision_strength_scale=1.    ;not used


temp=10.                          ;field plasma temperature
density=1d10                      ;field plasma density
threshold_escape_kev=0.           ;modified escape: threshold for trapping



;do subcomputation a


;itau=5d-6
itau=4.75d-6
iacc=6d-4

tauescape=itau/iacc;sqrt(itau*taumax/iaccmax)
avckomega=3d
utdivbyub=iacc/avckomega

IF NOT file_exist(dir) THEN file_mkdir,dir

niter=20000L
dt=500.;otherwise we do not get equilibrium


inputpar={dir:dir,temp:temp,density:density,tauescape:tauescape,avckomega:avckomega, $
          utdivbyub:utdivbyub,clmblog:clmblog,eref:eref,steps_per_decade:steps_per_decade, $
          minen:minen,maxen:maxen,threshold_escape_kev:threshold_escape_kev, $
          collision_strength_scale:collision_strength_scale,niter:niter,dt:dt, $
          dimless_time_unit:2.09d-7}

save,inputpar,filename=dir+'inputpar.sav'


;transform data and do sim


N=inputpar.steps_per_decade*(inputpar.maxen-inputpar.minen) ; total number of grid points
y=dindgen(N)/(N-1)*(inputpar.maxen-inputpar.minen)+inputpar.minen 
; location in energy of the grid points
; distribuited uniformly in log scale
; new variable y instead of E!
E=10d^y ; linear energy grid, old variable E (dimensionless, in units of mc^2)

etherm=kel2kev(inputpar.temp*1d6)/inputpar.eref
ytherm=alog10(etherm)
startgrid=inputpar.density*pg_maxwellian(e,etherm)


;escapeok=inputpar.dimless_time_unit*inputpar.dt/inputpar.tauescape

pg_cn_millerfix,startdist=startgrid,ygrid=y,ytherm=ytherm,niter=inputpar.niter $ ;1000L $
               ,diagnostic=d,accfactor=1. $ 
               ,xrange=[1d-8,1d10],yrange=[1d-5,1d15],dt=inputpar.dt $ ;1000d $
               ,avckomega=inputpar.avckomega,utdivbyub=inputpar.utdivbyub,/relescape $
               ,tauescape=inputpar.tauescape,maxwsrctemp=ytherm,noplot=1 $
               ,/compensate,density=inputpar.density,clmblog=inputpar.clmblog $
               ,threshold_escape_kev=inputpar.threshold_escape_kev $
               ,collision_strength_scale=inputpar.collision_strength_scale $
               ,allsave=0
      

;to do
pg_savesim,d,savedir=inputpar.dir




;pg_cn_dosim,inputpar,/convert,/saveall,/doplot,/preview,/couple_tau_ut





;load sim, do movie frames....
dir='~/work/ttd/movdata/res/'

pg_loadsim,savedir=dir,nsim=1,/quiet,da=da
;pg_reswidget,da

;get data etc...


nframes=250

wsize=[800,600]

wdef,1,wsize[0],wsize[1]

tmin=1d-5
tmax=2.

t=exp(findgen(nframes)/(nframes-1)*(alog(tmax)-alog(tmin))+alog(tmin))


eref=511.

energy=da.energy
ekev=energy*eref

mxw=1d10*pg_maxwellian(energy,da.etherm)

this_iter=100L
sp=da.grid[*,this_iter]

this_time=da.tottime[this_iter]*da.th

time=da.tottime[*]*da.th

fraciter=interpol(findgen(n_elements(time)),time,t)

;choose x & y range etc.

;plot spectral index somewhere?

;logarithmic time with bar?

loadct,0
linecolors
!p.background=255
!p.color=0
!p.charsize=2

pg_setplotsymbol,'CIRCLE',size=1.5


eind=where( ekev GE 30 AND ekev LE 80 )
lekev=alog(ekev[eind])
;resa=pg_phspectratoindex(pspa,emin=30.,emax=50.,enorm=40. $
;                         ,el_emin=30.,el_emax=80.,el_enorm=50. )


.run
FOR i=0,nframes-1 DO BEGIN 

indlow=floor(fraciter[i])
indhigh=indlow+1

fp=fraciter[i]-indlow

splow=da.grid[*,indlow]
sphigh=da.grid[*,indhigh]

sp=splow+fp*(sphigh-splow)


plot,ekev,mxw,/xlog,/ylog,yrange=[1d0,1d10],xrange=[1,300] $
    ,psym=-6,xtitle='energy (keV) ',/xst,/yst,/nodata $
    ,ytitle='density (electrons '+textoidl(' cm^{-3} keV^{-1}')+')' ;$
    ;,title=string(i)

oplot,ekev,mxw/eref,thick=4,color=12

oplot,ekev,sp/eref,thick=3,color=10
oplot,ekev,sp/eref,psym=8,color=10

oplot,30*[1,1],[1d0,1.8d7],color=2,linestyle=2,thick=2
oplot,80*[1,1],[1d0,1.8d7],color=2,linestyle=2,thick=2

d=linfit(lekev,alog(sp[eind]))

spindex=d[1]

xyouts,2,1d1,'Spectral Index: '+strtrim(string(spindex,format='(f12.1)'),2),/data


pos1=convert_coord([25,2d8],/data,/to_normal) 
pos2=convert_coord([200,1d9],/data,/to_normal) 

plot,[0,0],/nodata,xrange=[1d-5,2],yrange=[0,1],/ystyle $
    ,/xlog,/xst,position=[pos1[[0,1]],pos2[[0,1]]],yticks=1 $
    ,charsize=2.,/noerase,ytickname=[' ',' '] $
    ,xticks=4,xtickv=[1d-4,1d-3,1d-2,1d-1,1],xticklen=0.1 $
    ,xtickname=textoidl(['10^{-4}',' ','10^{-2}',' ','1']) $
    ,title='time (s)' ;,xtickformat='(e6.0)'

polyfill,[10^!X.crange[0],t[[i,i]],10^!X.crange[[0,0]]] $
        ,[0,0,1,1,0],color=5
oplot,t[i]*[1,1],!Y.crange,thick=3

axis,10^!X.crange[0],0,/yaxis,yticks=1,ytickname=[' ',' '],yrange=[0,1],/ystyle,yticklen=1d-5
axis,1,1,/xaxis ,xticks=4,xtickv=[1d-4,1d-3,1d-2,1d-1,1],xticklen=0.1 $
    ,xtickname=[' ',' ',' ',' ',' ']
axis,1,0,/xaxis ,xticks=4,xtickv=[1d-4,1d-3,1d-2,1d-1,1],xticklen=-0.1 $
    ,xtickname=[' ',' ',' ',' ',' ']
 

filename='~/work/ttd/movdata/frames/f_'+smallint2str(i,strlen=3)+'.png'

im=tvrd(/true)
write_png,filename,im


ENDFOR
end



;pg_loadsim,savedir=dir,nsim=1,/quiet,da=da
;pg_reswidget,da
