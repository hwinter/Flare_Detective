PRO hsi_check_pileup,os,tr,segment=segment,det=det,stop=stop

; hsi_check_pileup,os,['2002/07/23 00:29:40','2002/07/23 00:30:00'],det=[1,0,1,1,1,1,0,1,1],/stop
; hsi_check_pileup,os,['2002/07/23 00:33:40','2002/07/23 00:33:50'],det=[1,0,1,1,1,1,0,1,1],/stop
; hsi_check_pileup,os,['2002/07/23 00:29:40','2002/07/23 00:30:00'],segment=4,/stop
; hsi_check_pileup,os,['2002/07/23 00:38:30','2002/07/23 00:38:50'],segment=4,/stop
; hsi_check_pileup,os,['2002/04/10 12:28:40','2002/04/10 12:28:50'],det=[1,0,1,1,1,1,0,1,1],/stop
; hsi_check_pileup,os,['2002/04/10 12:28:00','2002/04/10 12:28:10'],det=[1,0,1,1,1,1,0,1,1],/stop
; hsi_check_pileup,os,['2002/04/10 12:30:00','2002/04/10 12:30:10'],det=[1,0,1,1,1,1,0,1,1],/stop
; hsi_check_pileup,os,['2002/04/10 12:30:30','2002/04/10 12:30:40'],det=[1,0,1,1,1,1,0,1,1],/stop
; hsi_check_pileup,os,['2002/04/21 01:23:30','2002/04/21 01:24:00'],det=[1,0,1,1,1,1,0,1,1],/stop
; hsi_check_pileup,os,['2002/04/21 01:28:30','2002/04/21 01:29:00'],det=[1,0,1,1,1,1,0,1,1],/stop
; hsi_check_pileup,o,['2003/01/24 03:10:50','2003/01/24 03:12:50'],det=[1,0,1,1,1,1,0,1,1],/stop
; hsi_check_pileup,o,['2002/05/02 01:48:00','2002/05/02 01:48:10'],det=[1,0,1,1,1,1,0,1,1],/stop

; first order correction for pile up (using david smith program
; hsi_correct_pileup.pro). this tends to slightly overestimate
; pile up.


; input:  tr    time_range
;         det   det_index_mask (or use segment for sigle detector)

; output: plots corrected and uncorrected spectrum (use stop keyword to access data)
;         os    spectrum object

; questions/problems to sa"m  krucker@ssl.berkeley.edu


;.comp ~/work/mfl2/may2003/hsi_check_pileup.pro

;get data (spectrum)
os=hsi_spectrum()
os->set,obs_time_int=tr
os->set,sp_energy_binning=1
;select a segment
if keyword_set(segment) then begin
  det=bytarr(18)
  det(segment)=1
endif
;number of segments used
nseg=total(det)
os->set,seg_index_mask=det
;select time range
ttt=max(anytim(tr))-min(anytim(tr))
os->set,sp_time_interval=ttt
os->set,time_range=[0,0]
sp=os->getdata()

;energy axis
eaxis=os->getaxis()
de=os->get(/sp_data_de)
eedge=[eaxis(0)-de(0)/2.,eaxis+de/2.]
;or use
;   os->getaxis(/energy, /edges_2)
;   os->getaxis(/energy)

;get live time
print,'now getting live time ...'
o=hsi_monitor_rate()
d=o->getdata(obs_time_interval=tr)
s=o->get()
t=d.time+s.mon_ut_ref
time=t
ttitle=strmid(anytim(time(0),/yy),0,20)+' - '+strmid(anytim(max(time),/yy),10,10)
ltime=d.live_time[0]
ltitle='live time = '+strtrim(fix(100*average(ltime)+0.5),2)+'%'
print,'averaged live time is '+average(ltime)*100+' %'

;david's pile up program
inspec=sp
livetime=average(ltime)
hsi_correct_pileup,inspec,eedge,segment=segment,livetime,outspec
 
 
;plot results
loadct,5
plot_oo,eaxis,inspec,xrange=[8,120],xstyle=1,xtitle='energy [keV]',ytitle='counts',$
   title=ttitle+': '+ltitle+' (corrected spectra in red)'
oplot,eaxis,outspec,color=122
oplot,eaxis,inspec-outspec
 
plot_oi,eaxis,inspec/outspec
plot_oo,eaxis,(inspec-outspec)/inspec,xrange=[8,120],xstyle=1,xtitle='energy [keV]',$
   title=ttitle+': '+ltitle,ytitle='pile up counts/all counts'
 
loadct,5
plot_oo,eaxis,inspec/de/ttt/nseg,xrange=[3,120],xstyle=1,xtitle='energy [keV]',$
   ytitle='counts s!U-1!N keV!U-1!N segment!U-1!N',thick=2,$
   ystyle=1,yrange=[min(inspec/de/ttt/nseg)/5,2*max(inspec/de/ttt/nseg)],$
   title=ttitle+': '+ltitle+' (corrected spectrum in red)'
oplot,eaxis,outspec/de/ttt/nseg,color=122,thick=2
oplot,eaxis,(inspec-outspec)/de/ttt/nseg,linestyle=1
oplot,eaxis,(inspec-outspec)/outspec
 
if keyword_set(stop) then stop
 
 
END    
























