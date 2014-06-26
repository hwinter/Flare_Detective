;+
;NAME:
; obs_summ_page.pro
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
; obs_summ_page,time_interval
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
;	/CORRECTED_COUNTRATE: if set, will plot corrected countrates 
;          instead of the default raw count rates.
;
;	/GOES : if set, will plot GOES data instead of normalized 
;          modulation.
;		if set to 2, will add GOES events labels
;
;	/NOCRASH: if set, routine will not crash if something goes 
;          wrong (lack of data, etc...)
;
;	filename: if used, will make a PNG output using the value of
;	   the keyword as filename; gives the postscript filename if
;	   combined with the PS keyword
;
;       /PS : if set, will direct the output to a postscript file named
;          idl.ps or, if filenmae is set, to <filename>.ps
;		PS=1 : B&W
;		PS=2 : Color
;
;	/LIVETIME: if set, puts detector livetimes instead of geomagnetic latitude.
;		if a 2-D array, it'll be used as yrange for the plot.
;	
;	/PARTICLES: if set, replaces high energy countrates by LO/HI particle rates from monitor rates
;
;	/SEGMENTS: if set, low & high energy countrates are replaced by countrates in front & rear segments
;			this keyword supersedes the /PARTICLES, /CORRECTED_COUNTRATE and /GOES keywords.
;
;	/OLD_WINDOW: if set, and using the 'X' device, will use the previous window, not create a new one.
;
;	/LIN: countrates (Countrates, segments, particles) are displayed in linear scale instead of log scale.
;
;	/SAS: will plot the size of the SAS reduced triangle. Setting it to 2 will use the Observing Summary's sqrt value.
;
;	/ENERGY: the FRONT decimation channels will be converted to energies, using Paolo's routine.
;
;	/POINTING: will plot (x,y) pointing and roll period instead of countrates, as well as sqrt of size of reduced SAS triangle.
;	
;
;EXAMPLE:
;	obs_summ_page,'2002/02/26 '+['10:20','10:35'],/GOES
;
;HISTORY:
;	Written in a hurry on 2002/04/14 by PSH
;
;	Modified: 2002/04/16 : added aspect solution
;	Modified: 2002/04/30 : modified to be graphics
;	   device-independant, removed keyword JPG
;	Modified: 2002/08/19 : modified to accomodate new structure
;	   definitions for obs. summary objects. 
;	Modified: 2002/09/11 : because somebody goofed up again: rates
; 	   are now sometimes compressed! 
;	Modified: 2002/10/03 : added new flags.
;	Modified: 2002/10/03A: uses linecolors.pro instead of myct3.pro
;	Modified: 2002/10/11: Modified to accomodate PS device
;	   (i.e. just changed charsize). 
;	Modified: 2002/11/22: 	replaced REAR_DECIMATION flag by
;	   NMZ_FLAG + SMZ_FLAG; added keyword /CORRECTED_COUNTRATE;
;	   added keyword /GOES 
;	Modified: 2002/11/27: Uses GOES-8 three-second data instead of
;	   1-minute data. 
;	Modified: 2003/01/10: Uses some additional new flags
;	   (REAR_DEC_WEIGHT, ...). Uses Paolo's 'plotgoes' instead of
;	   'goes_plot' (which has 
;          been changed in a BAD manner to accomodate GOES 10...) 
;       Modified: 2003/01/30: PS keyword introduced to facilitate
;          printing by GP.
;	Modified: 2003/05/21: added /LIVETIME keyword + some minor aesthetical changes.
;	Modified: 2003/05/29: FRONTS_OFF flag is also displayed.
;	Modified: 2003/06/12: Added /PARTICLES keyword
;	Modified: 2003/07/30: Added /SEGMENTS keyword + says nicely when no GOES data are available.
;	Modified: 2003/09/08: Added /OLD_WINDOW keyword
;	Modified: 2003/09/18: Added /LIN keyword
;	Modified: 2003/11/14: Added /SAS keyword
;	Modified: 2004/02/11: Uses Paolo's pg_plotgoes.pro routine for GOES stuff...
;	Modified: 2004/04/30: Added keyword /ENERGY
;	Modified: 2004/06/13: Added keyword /POINTING
;	Modified: 2004/08/05: Added FRONT_RATIO_1225 and BAD_PACKETS flags...
;	Modified: 2005/03/02: keyword GOES=2 : adds some GOES event labels
;	Modified: 2005/05/04: keyword PS=2 for color PS plots...
;	Modified: 2005/05/13: Modified SAS call (with Martin): Now
;	also works when I start at night!!!
;       Paolo Grigis: shortened as a way to get a quick and dirty obs
;       summ lightcurve
;-



PRO pg_hsiltc,time_intv,filename=filename,NOCRASH=NOCRASH,CORRECTED_COUNTRATE=CORRECTED_COUNTRATE,GOES=GOES,PS=PS,LIVETIME=LIVETIME, PARTICLES=PARTICLES, SEGMENTS=SEGMENTS, OLD_WINDOW=OLD_WINDOW, LIN=LIN, SAS=SAS, ENERGY=ENERGY,POINTING=POINTING

;clear_utplot
;xsize=800;900
;ysize=900
charsize=1.0

IF KEYWORD_SET(LIN) THEN LIN=1 ELSE LIN=0




	  LOADCT,1
	  linecolors

oso=OBJ_NEW('hsi_obs_summary')
oso->set,obs_time_interval=time_intv
title='HESSI Observing Summary, starting on '+anytim(time_intv[0],/ECS,/trunc)+' UT'

	
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
;========================
;corrected countrates ???	
IF KEYWORD_SET(CORRECTED_COUNTRATE) THEN BEGIN
	ro=OBJ_NEW('hsi_obs_summ_rate')
	ro->set,obs_time_interval=time_intv
	tmp=ro->getdata()
	rates=ro->corrected_countrate()
	OBJ_DESTROY,ro
ENDIF
;========================
;----------- below 100 keV
	maxcts=MAX(rates[0:5,*])
	IF LIN THEN yrng=[0,maxcts] ELSE yrng=[1,maxcts]
				
	utplot,times-times[0],rates[0,*],times[0], xtitle='', $
		ytitle='counts/s/detector',color=2,yrange=yrng, xstyle=1,$
		title=title,charsize=charsize,YLOG=1-LIN
	
	FOR i=1,4 DO BEGIN
		CASE i OF
			1: color=4
			2: color=5
			3: color=7
			ELSE: color=9
		ENDCASE
		outplot,times-times[0],rates[i,*], color=color	
	ENDFOR

	plot_label,/NOLINE,/DEV,[0.03,-1],'3-6 keV',color=2;,charsize=charsize/2
	plot_label,/NOLINE,/DEV,[0.03,-2],'6-12 keV',color=4;,charsize=charsize/2
	plot_label,/NOLINE,/DEV,[0.03,-3],'12-25 keV',color=5;,charsize=charsize/2
	plot_label,/NOLINE,/DEV,[0.03,-4],'25-50 keV',color=7;,charsize=charsize/2
	plot_label,/NOLINE,/DEV,[0.03,-5],'50-100 keV',color=9;,charsize=charsize/2


;some cleaning up:

OBJ_DESTROY,oso

END



