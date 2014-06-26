; EXAMPLE:
;	plot_goes_tem, '2002/02/26 '+['10:26','10:30'], '2002/02/26 '+['10:25:30','10:26'] 
;
;
;

PRO plot_goes_tem, time_intv, back_intv, PS=PS, EMyr=EMyr, Tyr=Tyr, EMlin=EMlin
	!P.MULTI=[0,1,3]
	IF KEYWORD_SET(PS) THEN BEGIN
		old_device=!D.NAME
		set_plot,'PS'
		plotgoes,time_intv,sat=8,/ylog,int=5,yticklen=1,yminor=1,linestyle=0,yrange=[1e-8,1e-3],xstyle=1,ymar=[1,1],xtitle='',charsize=2.0,thick=2               
		plotgoes,time_intv,sat=8,int=5,linestyle=1,channel=2,/over 
	ENDIF ELSE BEGIN			
		linecolors
		plotgoes,time_intv,sat=8,/ylog,int=5,yticklen=1,yminor=1,color=7,yrange=[1e-8,1e-3],xstyle=1,ymar=[1,1],xtitle='',charsize=2.0,thick=2               
		plotgoes,time_intv,sat=8,int=5,color=12,channel=2,/over 
	ENDELSE

	rd_goes,goes_times,goes_data,trange=time_intv
	rd_goes,bgoes_times,bgoes_data,trange=back_intv
	
	lo=goes_data[*,0]-MEAN(bgoes_data[*,0])
	hi=goes_data[*,1]-MEAN(bgoes_data[*,1])
	
	goes_tem,lo,hi,t,em,/GOES8
	
	utplot,goes_times-goes_times[0],t/11.594,ytit='Temperature [keV]',charsize=2.0,xstyle=1,xtit='',ymar=[1,1],yr=Tyr
	IF KEYWORD_SET(EMyr) THEN utplot,goes_times-goes_times[0],em,ytit='EM {x10!U49!N cm!U-3!N]',charsize=2.0,xstyle=1,xtit='',ymar=[2,1],yr=EMyr,YLOG=1-KEYWORD_SET(EMlin) ELSE utplot,goes_times-goes_times[0],em,ytit='EM {x10!U49!N cm!U-3!N]',charsize=2.0,xstyle=1,xtit='',ymar=[2,1],yr=[1e-4,1e4],YLOG=1-KEYWORD_SET(EMlin)

	IF KEYWORD_SET(PS) THEN BEGIN
		DEVICE,/CLOSE
		set_plot,old_device
	ENDIF
	!P.MULTI=0
END
