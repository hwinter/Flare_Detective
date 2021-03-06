;+
;NAME:
; hedc_time_profiles.pro
;
;PROJECT:
;	HESSI at ETHZ
;
;CATEGORY:
; 
;PURPOSE:
;
;PLANNED IMPROVEMENT/MODIFICATIONS:
;	endless...
;
;CALLING SEQUENCE:
; hedc_time_profiles,time_interval
;
;INPUT:
; time_interval = a 2-element array,in a format accepted by ANYTIM
;
;OPTIONAL INPUT:	
;
;OUTPUT:
; Observing Summary Information for that time range
;
;KEYWORDS:
;
;	filename: if used, will make a PNG output using the value of
;	   the keyword as filename; gives the postscript filename if
;	   combined with the PS keyword
;
;       /PS : if set, will direct the output to a postscript file named
;          idl.ps or, if filename is set, to <filename>.ps
;
;EXAMPLE:
;	hedc_time_profiles,'2002/02/26 '+['10:20','10:35'] ,filename='test.png'
;
;HISTORY:
;	Written 2002/08/29 by PSH, from obs_summ_page.pro
;	V2: PSH, 2003/11/14. Added SAS Reduced Triangle
;	V3: PSH, 2005/03/08. Added keyword /NO_RHESSI_SPG
;
;-



PRO hedc_time_profiles,time_intv,filename=filename, PS=PS, NO_RHESSI_SPG=NO_RHESSI_SPG, NOCRASH=NOCRASH
	;,CORRECTED_COUNTRATE=CORRECTED_COUNTRATE,GOES=GOES,LIVETIME=LIVETIME, PARTICLES=PARTICLES, SEGMENTS=SEGMENTS

Error_Status=0
IF KEYWORD_SET(NOCRASH) THEN CATCH, Error_Status
	IF Error_Status NE 0 THEN BEGIN
		CATCH,/CANCEL
		PRINT,'...............................CAUGHT ERROR !...................................'
		PRINT,'..........................ERROR MESSAGES:........................................'
		HELP, /Last_Message, Output=theErrorMessage
		FOR j=0,N_Elements(theErrorMessage)-1 DO PRINT, theErrorMessage[j]
		PRINT,'..........................END OF ERROR MESSAGES...................................'
		GOTO,THEEND
	ENDIF

ny=22 ; MUST BE EVEN NUMBER.
IF KEYWORD_SET(NO_RHESSI_SPG) THEN ny=ny-4
goesbig=1 ; set to 0 (if total nbr of plots is even) or 1 (if total nbr of plots is odd)...

clear_utplot
xsize=800
ysize=ny*100
charsize=1.5

IF keyword_set(PS) THEN BEGIN

     PS=1
     old_dev       = !D.NAME
     old_x_thick   = !X.THICK
     old_y_thick   = !Y.THICK
     old_charthick = !P.CHARTHICK
     old_p_thick   = !P.THICK

     !P.THICK      = 3
     !X.THICK      = 3
     !Y.THICK      = 3
     !P.CHARTHICK  = 3
     charsize      = 1

     set_plot, 'PS' 
     LOADCT,0
     device,/portrait

     ; OFFSET and SIZE for A4 sheets in cm	
	;device,XSIZE=18,YSIZE=24,YOFFSET=3
	DEVICE,XSIZE=11,YSIZE=16,XOFFSET=0,YOFFSET=0
  
     IF keyword_set(filename) THEN BEGIN
        DEVICE,FILENAME = filename+'.ps'
     ENDIF
   
ENDIF ELSE PS=0

CASE !D.NAME OF 
	'Z': BEGIN DEVICE,/CLOSE & DEVICE, set_resolution=[xsize,ysize] & END
	'X': BEGIN WINDOW,xs=xsize,ys=ysize,/FREE & END
	'PS': BEGIN charsize=1. & END
	ELSE: PRINT,"This routine wasn't designed or tested for graphic devices other than X, Z or PS: try at your own risk!"
ENDCASE

!P.MULTI=[0,1,ny]

; make B-W plot in case of keyword PS set

IF NOT keyword_set(PS) THEN BEGIN
  LOADCT,5
  linecolors
  TVLCT,r,g,b,/GET
ENDIF

oso=obj_new('hsi_obs_summary')
oso->set,obs_time_interval=time_intv
title='RHESSI time profiles, starting on '+anytim(time_intv[0],/ECS,/trunc)+' UT'

;====================================================================================
;count rates
;====================================================================================
	rates_struct=oso->getdata()
	rates=rates_struct.COUNTRATE
	IF datatype(rates) EQ 'BYT' THEN BEGIN
		PRINT,".............. WARNING: looks like rates are in compressed (BYTE) form....... decompressing....."
		rates=hsi_obs_summ_decompress(rates)
	ENDIF
	times=oso->getdata(/time)

;----------- below 100 keV
	maxcts=MAX(rates[0:5,*])
				
	utplot,times-times[0],rates[0,*],times[0], xtitle='', $
		ytitle='cts/s/det',color=2,yrange=[1,maxcts], xstyle=1,$
		title=title,charsize=charsize,xmargin=[10,1],ymargin=[0,2],/ylog,XTICKNAME=REPLICATE(' ',10)
	
	FOR i=1,4 DO BEGIN
		CASE i OF
			1: color=4
			2: color=5
			3: color=7
			ELSE: color=9
		ENDCASE
		outplot,times-times[0],rates[i,*], color=color	
	ENDFOR

	plot_label,/DEV,[0.03,-1],'3-6 keV',NOLINE=1-PS,linestyle=1*PS,color=2*(1-PS)+255*PS,charsize=charsize/2
	plot_label,/DEV,[0.03,-2],'6-12 keV',NOLINE=1-PS,linestyle=2*PS,color=4*(1-PS)+255*PS,charsize=charsize/2
	plot_label,/DEV,[0.03,-3],'12-25 keV',NOLINE=1-PS,linestyle=3*PS,color=5*(1-PS)+255*PS,charsize=charsize/2
	plot_label,/DEV,[0.03,-4],'25-50 keV',NOLINE=1-PS,linestyle=4*PS,color=7*(1-PS)+255*PS,charsize=charsize/2
	plot_label,/DEV,[0.03,-5],'50-100 keV',NOLINE=1-PS,linestyle=5*PS,color=9*(1-PS)+255*PS,charsize=charsize/2

;------------ above 100 keV 
	maxcts=MAX(rates[5:8,*])
				
	utplot,times-times[0],rates[5,*],times[0], xtitle='', $
		ytitle='cts/s/det',color=2,yrange=[1,maxcts], xstyle=1,$
		title='',charsize=charsize,xmargin=[10,1],ymargin=[1,1],/ylog
		
	FOR i=6,8 DO BEGIN
		CASE i OF
			6: color=4
			7: color=5
			ELSE: color=7
		ENDCASE
		outplot,times-times[0],rates[i,*], color=color	
	ENDFOR

	plot_label,/DEV,[0.03,-1],'0.1-0.3 MeV',NOLINE=1-PS,linestyle=1*PS,color=2*(1-PS)+255*PS,charsize=charsize/2
	plot_label,/DEV,[0.03,-2],'0.3-0.8 MeV',NOLINE=1-PS,linestyle=2*PS,color=4*(1-PS)+255*PS,charsize=charsize/2
	plot_label,/DEV,[0.03,-3],'0.8-7 MeV',NOLINE=1-PS,linestyle=3*PS,color=5*(1-PS)+255*PS,charsize=charsize/2
	plot_label,/DEV,[0.03,-4],'7-20 MeV',NOLINE=1-PS,linestyle=4*PS,color=7*(1-PS)+255*PS,charsize=charsize/2

;====================================================================================
;Flags
;====================================================================================
!P.MULTI=[ny/2 -1,1,ny/2]	
	flagdata_struct=oso->getdata(class_name='obs_summ_flag')
	flagdata=flagdata_struct.FLAGS
	flaginfo=oso->get(class_name='obs_summ_flag')
	flagtimes=oso->getdata(class_name='obs_summ_flag',/time)

	; 'bit-like' flags:
	wantedflags=[0,1,2,11,12,16,17,14]
	IF flaginfo.flag_ids[24] EQ 'PARTICLE_FLAG' THEN wantedflags=[24,wantedflags]
;	IF flaginfo.flag_ids[26] EQ 'PARTSTORM' THEN wantedflags=[26,wantedflags]	
	IF flaginfo.flag_ids[23] EQ 'AAZ_FLAG' THEN wantedflags=[23,wantedflags]	
	IF flaginfo.flag_ids[30] EQ 'FRONTS_OFF' THEN wantedflags=[30,wantedflags]	
	i=0

	utplot,flagtimes-flagtimes[0],flagdata(wantedflags(i),*),flagtimes[0],charsiz=charsize,xmargin=[10,1],ymargin=[0,2],xtitle='', xstyle=1,$
		yrange=[-2,1+2*N_ELEMENTS(wantedflags)],ytickname=[' ',' ',' ',' ',' ',' ',' ',' '],ytitle='Flags',yticklen=0.00001,ystyle=1,/NODATA,tit='RHESSI Obs. Summary flags',XTICKNAME=REPLICATE(' ',10)

	FOR i=0,N_ELEMENTS(wantedflags)-1 DO BEGIN
		fdata=flagdata(wantedflags[i],*)
		
		CASE wantedflags[i] OF
			0: color=2	;SAA
			1: color=10	;NIGHT
			2: color=5	;FLARE
			11: BEGIN 
				color=4	;TRANSMITTER
				fdata=FLOAT(fdata)/100.
			END
			12: BEGIN
				color=5	;SUNLIGHT
				fdata=FLOAT(fdata)/100.
			END			
			14: color=12	;ATTENUATOR
			16: color=9	;NONSOLAR
			17: color=2	;GAP
			23: color=6	;AAZ_FLAG
			24: color=4	;PARTICLE_FLAG
			26: color=4	;PARTSTORM
			30: color=7	;FRONTS_OFF
			ELSE:color=9
		ENDCASE
		outplot,flagtimes-flagtimes[0],2*i-1+fdata,flagtimes[0], color=color
		XYOUTS,/DATA,flagtimes[0.02*N_ELEMENTS(flagtimes)]-flagtimes[0],2*i-1,flaginfo.flag_ids(wantedflags[i]),color=color,charsize=charsize/2
	ENDFOR

!P.MULTI=[ny-4,1,ny]	

	; decimation flags:
	wantedflags=[18,19]
	IF flaginfo.flag_ids[25] EQ 'REAR_DECIMATION' THEN  wantedflags=[wantedflags,25]
	IF flaginfo.flag_ids[25] EQ 'REAR_DEC_CHAN/128' THEN  wantedflags=[wantedflags,25]
	IF flaginfo.flag_ids[29] EQ 'REAR_DEC_WEIGHT' THEN  wantedflags=[wantedflags,29]

	yrange=[1,1000]
	utplot,flagtimes-flagtimes[0],flagdata[wantedflags[0],*],flagtimes[0],charsiz=charsize,xmargin=[10,1],ymargin=[1,1],xtitle='', xstyle=1, color=250,$
		yrange=yrange,ytitle='DECIMATION!CChannel or weight',ystyle=1,/YLOG,/NODATA
	FOR i=0,N_ELEMENTS(wantedflags)-1 DO BEGIN
		fdata=flagdata(wantedflags[i],*)
		ligne=flaginfo.flag_ids(wantedflags[i])

		CASE wantedflags(i) OF			
			18: color=7	;DECIMATION_ENERGY
			19: color=4	; DECIMATION_WEIGHT
			25: BEGIN
				color=9	; REAR_DECIMATION
				IF flaginfo.flag_ids[25] EQ 'REAR_DECIMATION' THEN BEGIN
					fdata=flagdata[21,*]+flagdata[22,*]+flagdata[25,*]
					fdata=fdata+0.5
				ENDIF
			END
			ELSE:color=6
		ENDCASE
		outplot,flagtimes-flagtimes[0],fdata,flagtimes[0], color=color
		XYOUTS,/DATA,flagtimes(0.025*N_ELEMENTS(flagtimes))-flagtimes[0],yrange[1]/(3^(i+1)),ligne,color=color,charsize=charsize/2
	ENDFOR



	; other:
	wantedflags=[15]
	IF flaginfo.flag_ids[20] EQ 'MAX_DET_VS_TOT' THEN wantedflags=[wantedflags,20]
	yrange=[0,100]
	utplot,flagtimes-flagtimes[0],flagdata(wantedflags[0],*),flagtimes[0],charsiz=charsize,xmargin=[10,1],ymargin=[1,2] ,xtitle='', xstyle=1, color=5,$
		yrange=yrange,ytitle='Degrees or %',ystyle=1,tit='RHESSI geomagnetic latitude (absolute value) and other flags'
	XYOUTS,/DATA,flagtimes(0.025*N_ELEMENTS(flagtimes))-flagtimes[0],yrange(1)*2/3,flaginfo.flag_ids(wantedflags[0]),color=5,charsize=charsize/2
	FOR i=1,N_ELEMENTS(wantedflags)-1 DO BEGIN
		fdata=flagdata(wantedflags[i],*)
		ligne=flaginfo.flag_ids(wantedflags[i])

		CASE wantedflags(i) OF			
			20: color=4	;MAX_DET_VS_TOT
			ELSE:color=9
		ENDCASE
		outplot,flagtimes-flagtimes[0],fdata,flagtimes[0], color=color
		XYOUTS,/DATA,flagtimes[0.025*N_ELEMENTS(flagtimes)]-flagtimes[0],yrange[1]-(i+2)*yrange[1]/6,ligne,color=color,charsize=charsize/2
	ENDFOR

	ephdata_struct=oso->getdata(class_name='ephemeris')      
	ephdata=ephdata_struct.XYZ_ECI
	ephtimes=oso->getdata(class_name='ephemeris',/time)
	tmp=eci2geographic(ephdata[0:2,*],ephtimes)
	tmp=geo2mag(tmp[0:1,*])
	outplot,ephtimes-ephtimes[0],abs(tmp[0,*]), color=9
	XYOUTS,/DATA,0.02*(ephtimes[N_ELEMENTS(ephtimes)-1]-ephtimes[0]),yrange[1]*5/6,'Absolute geomagnetic latitude',color=9,charsize=charsize/2

;====================================================================================
; particle rates
;====================================================================================

	qmro=hsi_qlook_monitor_rate(obs_time_interval=time_intv)
	qmr=qmro->getdata()
	qmrtimes=qmro->getdata(/xaxis)
	OBJ_DESTROY,qmro
	maxcts=MAX(qmr.PARTICLE_RATE) > 10
	utplot,qmrtimes-qmrtimes[0],qmr.PARTICLE_RATE[1],ytit='Cts/s',	$
		color=3,yrange=[1,maxcts], xstyle=1, xtit='',$
		title='RHESSI particle rates',charsize=charsize,xmargin=[10,1],ymargin=[1,2],/ylog
	outplot,qmrtimes-qmrtimes[0],qmr.PARTICLE_RATE[0],color=2
	
	plot_label,/DEV,[0.03,-1],'LO channel',NOLINE=1-PS,linestyle=1*PS,color=2*(1-PS)+255*PS,charsize=charsize/2
	plot_label,/DEV,[0.03,-2],'HI channel',NOLINE=1-PS,linestyle=1*PS,color=3*(1-PS)+255*PS,charsize=charsize/2

;====================================================================================
; countrates in each segments
;====================================================================================

	qlo=hsi_qlook_rate_per_det()
	qlo->set,obs_time_interval=time_intv
	qlodata=qlo->getdata()
	IF datatype(qlodata.COUNTRATE) EQ 'BYT' THEN qlorates=hsi_obs_summ_decompress(qlodata.COUNTRATE) ELSE qlorates=qlodata.COUNTRATE
	qlotimes=qlo->getdata(/time)
	OBJ_DESTROY,qlo
	title='RHESSI count rates (per segments)'
	
	maxcts=MAX(qlorates[0:8,*])
	utplot,qlotimes-qlotimes[0],qlorates[0,*],qlotimes[0], trange=anytim(time_intv,/yoh), xtitle='', xstyle=1, $
		ytitle='FRONT!Ccts/s',color=2,yrange=[0,maxcts], $
		title=title,charsize=charsize,xmargin=[10,1],ymargin=[0,2],XTICKNAME=REPLICATE(' ',10)
	FOR i=1,8 DO outplot,qlotimes-qlotimes[0],qlorates[i,*],color=2+i
	plot_label,/DEV,[0.03,-1],'DETECTORS',NOLINE=1-PS,linestyle=1*PS,charsize=charsize/2
	FOR i=1,9 DO plot_label,/DEV,[0.1+i*0.01,-1],strn(i),NOLINE=1-PS,linestyle=1*PS,color=(1+i)*(1-PS)+255*PS,charsize=charsize/2
	maxcts=MAX(qlorates[9:17,*])
	utplot,qlotimes-qlotimes[0],qlorates[9,*],qlotimes[0], trange=anytim(time_intv,/yoh), xtitle='', xstyle=1, $
		ytitle='REAR!Ccts/s',color=2,yrange=[0,maxcts], $
		charsize=charsize,xmargin=[10,1],ymargin=[1,1]
	FOR i=9,17 DO outplot,qlotimes-qlotimes[0],qlorates[i,*],color=1+i-8
	plot_label,/DEV,[0.03,-1],'DETECTORS',NOLINE=1-PS,linestyle=1*PS,charsize=charsize/2
	FOR i=1,9 DO plot_label,/DEV,[0.1+i*0.01,-1],strn(i),NOLINE=1-PS,linestyle=1*PS,color=(1+i)*(1-PS)+255*PS,charsize=charsize/2

;====================================================================================
;LIVETIME
;====================================================================================

		mro=hsi_monitor_rate()
		mro->set,obs_time_interval=time_intv
		mr=mro->getdata()
		utbase=mro->get(/mon_ut_ref)		
		OBJ_DESTROY,mro
		
	IF datatype(mr) EQ 'STC' THEN BEGIN
		; average front segments of detectors 1,3,4,5,6,9:
		data=AVG(mr.LIVE_TIME[[0,2,3,4,5,8],*],0)
		IF N_ELEMENTS(LIVETIME) NE 2 THEN yrange=[0.9,1.] ELSE yrange=LIVETIME
		utplot,utbase+mr.TIME-times[0],data,/NODATA,charsiz=charsize,yrange=yrange,xmargin=[10,1],ymargin=[1,2],xtitle='', xstyle=1,	$
			ytit='%', tit='RHESSI LIVETIME (avg of detectors 1,3,4,5,6 & 9)',XTICKNAME=REPLICATE(' ',10)
		outplot,utbase+mr.TIME-times[0],data,color=7
		;ss=WHERE(data LT 0.95)
		;IF ss[0] NE -1 THEN outplot,utbase+mr.TIME-times[0],data,color=3,linestyle=2
		plot_label,/DEV,[0.03,2],'FRONT SEGMENTS',NOLINE=1-PS,linestyle=1*PS,color=7*(1-PS)+255*PS,charsize=charsize/2

		; average front segments of detectors 1,3,4,5,6,9:
		data=AVG(mr.LIVE_TIME[[9,11,12,13,14,17],*],0)
		outplot,utbase+mr.TIME-times[0],data,color=8
		;ss=WHERE(data LT 0.95)
		;IF ss[0] NE -1 THEN outplot,utbase+mr.TIME-times[0],data,color=2,linestyle=1
		plot_label,/DEV,[0.03,1],'REAR SEGMENTS',NOLINE=1-PS,linestyle=1*PS,color=8*(1-PS)+255*PS,charsize=charsize/2
	ENDIF ELSE BEGIN
		PRINT,"Problems with monitor rates..."
		PLOT,FINDGEN(100),FINDGEN(100),xtit='',ytit='',xtickname=REPLICATE(' ',10),ytickname=REPLICATE(' ',10),color=0,/NODATA, xstyle=1,xmargin=[10,2],ymargin=[2,2]
		XYOUTS,20,50,/DATA,'LIVETIME -- Problems with Monitor Rates.',charsize=charsize/2
	ENDELSE

;====================================================================================
;mod variance
;====================================================================================
	;oso->plot,class_name='mod_variance',charsize=charsize,xmargin=[10,1],ymargin=[1,1],xtitle='', xstyle=1,title=''
	mvtimes=oso->getdata(class_name='mod_variance',/time)
	mvdata_struct=oso->getdata(class_name='mod_variance')
	mvdata=mvdata_struct.MOD_VARIANCE
	mvinfo=oso->get(class_name='mod_variance')
	
	utplot,mvtimes-mvtimes[0],mvdata[0,*]/10.,mvtimes[0], xtitle='',ytit='Normalized!Cmodulation',tit='RHESSI modulation variance (12-25 keV band)', xstyle=1,charsize=charsize,xmargin=[10,1],ymargin=[1,1],color=9,XTICKNAME=REPLICATE(' ',10)
	outplot,mvtimes-mvtimes[0],mvdata[1,*]/10.,color=12
	
	plot_label,/DEV,[0.03,-1],'Collimator '+strn(mvinfo.DIM1_IDS[0]),NOLINE=1-PS,linestyle=1*PS,color=9*(1-PS)+255*PS,charsize=charsize/2
	plot_label,/DEV,[0.03,-2],'Collimator '+strn(mvinfo.DIM1_IDS[1]),NOLINE=1-PS,linestyle=1*PS,color=12*(1-PS)+255*PS,charsize=charsize/2

;====================================================================================
;SAS solution
;====================================================================================
	ao=OBJ_NEW('psh_hsi_aspect_solution')
	ao->set,aspect_cntl_level=5 	
	ao->set,obs_time_interval=anytim(time_intv)
	;ao->set,aspect_time_range=anytim(time_intv)	
	as=ao->getdata(/no_range_test)
	IF datatype(as) EQ 'INT' THEN BEGIN
		PRINT,'Problem with SAS...
		as_quality=-1
	ENDIF ELSE BEGIN		
		as_qual=ao->get(/as_quality)	
		as_times=as.time * 2d^(-7)
		as_t0=hsi_sctime2any(as.t0)
		as_quality=*as_qual.triangle
	ENDELSE
	
	IF N_ELEMENTS(as_quality) GT 1 THEN BEGIN
		utplot,as_times,abs(as_quality),as_t0,xstyle=1,charsize=charsize,xmargin=[10,2],ymargin=[1,1],timerange=anytim(time_intv), xtitle='', ytitle='SAS', /YLOG,yrange=[0.01,100]
		plot_label,/DEV,/NOLINE,[0.03,-1],'Size of Reduced Triangle (absolute value) [arcsec]',color=12,charsize=charsize/2
	ENDIF ELSE BEGIN
		PLOT,FINDGEN(100),FINDGEN(100),xtit='',ytit='',xtickname=REPLICATE(' ',10),ytickname=REPLICATE(' ',10),color=0,/NODATA, xstyle=1,xmargin=[10,2],ymargin=[2,2]
		XYOUTS,20,50,/DATA,'Problems extracting size of SAS Reduced Triangle.',charsize=charsize/2
	ENDELSE
	IF OBJ_VALID(ao) THEN OBJ_DESTROY,ao
;====================================================================================
;Qlook pointing, roll_angle, roll_period
;====================================================================================

;====================================================================================
;GOES
;====================================================================================
IF goesbig THEN !P.MULTI=[ny/2-6,1,ny/2]
	;plot_goes,anytim(time_intv[0],/ECS),anytim(time_intv[1],/ECS),color=[4,7],/nodeftitle,xtitle='',ytitle='GOES-8 X-rays',xmargin=[10,1],ymargin=[1,1],charsize=charsize,thick=3,/three 	;/one_minute
	;rd_goes,goes_times,goes_data,trange=anytim(time_intv,/yoh)
	goo=OBJ_NEW('goes')
	goo->read,anytim(time_intv[0],/yoh),anytim(time_intv[1],/yoh),err=err
	IF err EQ '' THEN BEGIN
		pg_plotgoes,time_intv,/ylog,int=5,yticklen=1,yminor=1,color=7,yrange=[1e-8,1e-3],xstyle=1,xtitle='',xmargin=[10,1],ymargin=[1,1],charsize=charsize,thick=3,/outinfoytitle,title=''
		pg_plotgoes,time_intv,int=5,color=12,channel=2,/over 
	ENDIF ELSE BEGIN
		plot,FINDGEN(100),FINDGEN(100),xtit='',ytit='',xtickname=REPLICATE(' ',10),ytickname=REPLICATE(' ',10),color=0,/NODATA, xstyle=1,xmargin=[10,1],ymargin=[2,2]
		XYOUTS,/DATA,38,45,'Missing GOES data',charsize=charsize	
	ENDELSE
	goo->flush,1
	OBJ_DESTROY,goo
;====================================================================================
; corrected countrates
;====================================================================================
IF goesbig THEN !P.MULTI=[ny-14,1,ny]
	ro=OBJ_NEW('hsi_obs_summ_rate')
	ro->set,obs_time_interval=time_intv
	tmp=ro->getdata()
	rates=ro->corrected_countrate()
	OBJ_DESTROY,ro

;----------- below 100 keV
	maxcts=MAX(rates[0:5,*])
				
	utplot,times-times[0],rates[0,*],times[0], xtitle='', $
		ytitle='cts/s/det',color=2,yrange=[1,maxcts], xstyle=1,$
		title='RHESSI corrected countrates',charsize=charsize,xmargin=[10,1],ymargin=[0,2],/ylog,XTICKNAME=REPLICATE(' ',10)
	
	FOR i=1,4 DO BEGIN
		CASE i OF
			1: color=4
			2: color=5
			3: color=7
			ELSE: color=9
		ENDCASE
		outplot,times-times(0),rates[i,*], color=color	
	ENDFOR

	plot_label,/DEV,[0.03,-1],'3-6 keV',NOLINE=1-PS,linestyle=1*PS,color=2*(1-PS)+255*PS,charsize=charsize/2
	plot_label,/DEV,[0.03,-2],'6-12 keV',NOLINE=1-PS,linestyle=2*PS,color=4*(1-PS)+255*PS,charsize=charsize/2
	plot_label,/DEV,[0.03,-3],'12-25 keV',NOLINE=1-PS,linestyle=3*PS,color=5*(1-PS)+255*PS,charsize=charsize/2
	plot_label,/DEV,[0.03,-4],'25-50 keV',NOLINE=1-PS,linestyle=4*PS,color=7*(1-PS)+255*PS,charsize=charsize/2
	plot_label,/DEV,[0.03,-5],'50-100 keV',NOLINE=1-PS,linestyle=5*PS,color=9*(1-PS)+255*PS,charsize=charsize/2

;------------ above 100 keV 
	maxcts=MAX(rates[5:8,*])
				
	utplot,times-times[0],rates[5,*],times[0], xtitle='', $
		ytitle='cts/s/det',color=2,yrange=[1,maxcts], xstyle=1,$
		title='',charsize=charsize,xmargin=[10,1],ymargin=[2,1],/ylog
	
	FOR i=6,8 DO BEGIN
		CASE i OF
			6: color=4
			7: color=5
			ELSE: color=7
		ENDCASE
		outplot,times-times[0],rates[i,*], color=color	
	ENDFOR

	plot_label,/DEV,[0.03,-1],'0.1-0.3 MeV',NOLINE=1-PS,linestyle=1*PS,color=2*(1-PS)+255*PS,charsize=charsize/2
	plot_label,/DEV,[0.03,-2],'0.3-0.8 MeV',NOLINE=1-PS,linestyle=2*PS,color=4*(1-PS)+255*PS,charsize=charsize/2
	plot_label,/DEV,[0.03,-3],'0.8-7 MeV',NOLINE=1-PS,linestyle=3*PS,color=5*(1-PS)+255*PS,charsize=charsize/2
	plot_label,/DEV,[0.03,-4],'7-20 MeV',NOLINE=1-PS,linestyle=4*PS,color=7*(1-PS)+255*PS,charsize=charsize/2

IF NOT KEYWORD_SET(NO_RHESSI_SPG) THEN BEGIN
	;====================================================================================
	; RHESSI spectrogram: high energy
	;====================================================================================
	!P.MULTI=[3,1,ny/2]	
	spg=rapp_hsi_spg(time_intv,/high, xaxis=xaxis, yaxis=yaxis,/SEMICAL)
	clear_utplot
	xaxis=xaxis+anytim(time_intv[0])
	spectro_plot,spg,xaxis,yaxis,cbar=0,bottom=14,title='RHESSI semi-calibrated spectrogram (YLOG,ZLOG)',xmar=[10,1],ymar=[2,1],xtit=' ',charsize=charsize,ytit='keV',/ZLOG,/YLOG,xstyle=1,yr=[6,20000]
	;====================================================================================
	; RHESSI spectrogram: low energy
	;====================================================================================
	spectro_plot,spg,xaxis,yaxis,cbar=0,bottom=14,title='RHESSI semi-calibrated spectrogram (YLOG,ZLOG)',xmar=[10,1],ymar=[2,1],xtit=' ',charsize=charsize,ytit='keV',/ZLOG,/YLOG,xstyle=1,yr=[3,100]
ENDIF
;====================================================================================
; PHOENIX spectrogram
;====================================================================================
!P.MULTI=[1,1,ny/2]	
spg=rapp_get_spectrogram(time_intv,/ELIM,/BACK,/DESPIKE,xaxis=xaxis,yaxis=yaxis,/ANYTIM)
IF datatype(spg) NE 'STR' THEN BEGIN
		clear_utplot
		spectro_plot,spg,xaxis,yaxis,cbar=0,bottom=14,title='PHOENIX-2 radio spectrogram (background-subtracted)',xmar=[10,1],ymar=[2,1],xtit=' ',charsize=charsize,ytit='MHz',xstyle=1
ENDIF
;====================================================================================
;====================================================================================
THEEND:

PRINT,flaginfo.FLAG_IDS	; helps me see whenever there's any new stuff !

IF (KEYWORD_SET(filename)) AND NOT(keyword_set(ps)) THEN BEGIN
	TVLCT,r,g,b,/GET
	write_png,filename,TVRD(),r,g,b
ENDIF

IF keyword_set(PS) THEN BEGIN
    device, /close
    set_plot, old_dev

    !X.THICK     = old_x_thick 
    !Y.THICK     = old_y_thick
    !P.CHARTHICK = old_charthick
    !P.THICK     = old_p_thick

    IF NOT(keyword_set(filename)) THEN filename='idl' 
    PRINT,'   Image written to '+filename+'.ps!'
ENDIF

;some cleaning up:
!P.MULTI=0
OBJ_DESTROY,oso

END
