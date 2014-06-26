;.run for_ab_20040922

;LOADCT,0
;rag_adjct
c1=50
c2=75
!P.MULTI=[0,1,2]
	time_interval='2003/10/28 '+['09:00','15:30']
	;Phoenix-2 spg	
		fil='/ftp/pub/hedc/fs/data3/rag/phoenix-2/observations/2003/10/28/comb_nicer.fit'
		radio_spectro_fits_read,fil,image,xaxis,yaxis
		image=tracedespike(image,stat=5)
		spectro_plot,image,xaxis,yaxis,xstyle=1,ytit='Frequency [MHz]',xtit=' ',ymar=[1,0],xmar=[8,1],XTICKNAME=REPLICATE(' ',10),timerange=time_interval
		label_plot,0.8,0.3,'Phoenix-2',color=254
	;GOES lightcurves
		!P.MULTI=[2,1,4]
		pg_plotgoes,time_interval,/ylog,int=5,yticklen=1,yminor=1,color=c1,yrange=[1e-7,1e-2],xstyle=1,xtitle='',thick=2,title='',charsize=2,xmar=[8,1],ymar=[1,0],ytickname=['B1.0','C1.0','M1.0','X1.0','X10','X100'],XTICKNAME=REPLICATE(' ',10),ytit='GOES class',timerange=time_interval
		pg_plotgoes,time_interval,int=5,color=c2,channel=2,/over 
		label_plot,0.75,-1,'GOES-12 3s data'
	;RHESSI lightcurves
		ro=OBJ_NEW('hsi_obs_summ_rate')
		ro->set,obs_time_interval=time_interval
		tmp=ro->getdata()
		obstimes=ro->getdata(/xaxis)
		rates=ro->corrected_countrate()
		OBJ_DESTROY,ro
		r1=REFORM(rates[1,*])
		r2=REFORM(rates[2,*])
		r3=TOTAL(rates[3:4,*],1)
;CORRECTING THE RATES...
	;1st peak
	ss=WHERE(obstimes GE anytim('2003/10/28 11:00') AND obstimes LE anytim('2003/10/28 11:30'))
	; need to take uncorrected countrates...
	oso=hsi_obs_summary()
	oso->set,obs_time=time_interval
	urates=oso->getdata()
	OBJ_DESTROY,oso
		r1[ss]=urates[ss].COUNTRATE[1]*15.
		r2[ss]=urates[ss].COUNTRATE[2]*2.5
		r3[ss]=TOTAL(urates[ss].COUNTRATE[3:4],1)

	;2nd peak
	ss=WHERE(obstimes GE anytim('2003/10/28 12:45') AND obstimes LE anytim('2003/10/28 13:10'))
		r1[ss]=r1[ss]*0.3
		r2[ss]=r2[ss]*0.3
		r3[ss]=r3[ss]*0.3
						
utplot,obstimes-obstimes[0],r1,obstimes[0],color=c1,yr=[1d1,1d5],/YLOG,xstyle=1,ytit='[cts/s/det]',charsize=2,xmar=[8,1],ymar=[2,0],xtit='',timerange=time_interval
outplot,obstimes-obstimes[0],r2,color=c2
outplot,obstimes-obstimes[0],r3
;label_plot, 0.73, -1,'6-12 keV',/LINE,color=c1
;label_plot, 0.73, -2,'12-25 keV',/LINE,color=c2
;label_plot, 0.73, -3,'25-100 keV',/LINE
label_plot,0.65,-1,'RHESSI corrected countrates'
;---------------------------------------------------------------------------------------------------------------------------------------
END
