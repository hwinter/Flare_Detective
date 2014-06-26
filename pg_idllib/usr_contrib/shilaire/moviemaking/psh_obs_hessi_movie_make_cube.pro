; Each TRACE image will be assigned the HESSI images closest in time...
; Works also with EIT (and probably other) stuff...
;
;
;
;
; RETURNS cube.
;
; PLANNED IMPROVEMENTS:
;	Add GOES lightcurves, Phoenix-2 spg,...
;	Should work without HESSI tesseract file...
;
; IF the time difference between a TRACE image and its nearest HESSI image is more than 'max_time_diff' (def: 60. secs), the HESSI image is forgotten.
;

FUNCTION psh_obs_hessi_movie_make_cube, mainfiles, hessifile, obs_time_intv=obs_time_intv, max_time_diff=max_time_diff,min_nbr_counts=min_nbr_counts, ebands_ss=ebands_ss, dt=dt, NOFRAMENBR=NOFRAMENBR, drange=drange, EIT=EIT
			
	IF NOT KEYWORD_SET(max_time_diff) THEN 	max_time_diff=59.
	IF NOT KEYWORD_SET(dt) THEN dt=30.
	hessimapptr=psh_fits2map(hessifile, ext1=ctrlinfo)	
	IF tag_exist(ctrlinfo,'im_time_interval') THEN hessi_tintvs=ctrlinfo.im_time_interval ELSE hessi_tintvs=ctrlinfo.times_arr
	hessitimes=avg(hessi_tintvs,0)
PRINT,'HESSI mid-bin times:' & ptim,hessitimes
	IF NOT KEYWORD_SET(obs_time_intv) THEN obs_time_intv=[anytim(hessitimes[0]),anytim(hessitimes[N_ELEMENTS(hessitimes)-1])]+[-300,600]
	IF tag_exist(ctrlinfo,'im_energy_binning') THEN ebands1=ctrlinfo.im_energy_binning ELSE ebands1=-1
	IF tag_exist(ctrlinfo,'ebands_arr') THEN ebands2=ctrlinfo.ebands_arr ELSE ebands2=-1
	IF N_ELEMENTS(ebands1[0,*]) GE N_ELEMENTS(ebands2[0,*]) THEN ebands=ebands1 ELSE ebands=ebands2
	n_ebands=N_ELEMENTS(ebands[0,*])	
	IF NOT KEYWORD_SET(ebands_ss) THEN ebands_ss=INDGEN(N_ELEMENTS(ebands[0,*]))
	n_ebands_ss=N_ELEMENTS(ebands_ss)
	
	hessi_FOV=[[ctrlinfo.xyoffset[0]+[-100,100]],[ctrlinfo.xyoffset[1]+[-100,100]]]
	loadct,1
	rainbow_linecolors
	basesize=300
	charsize=0.7

;get Obs. Summ. countrates (corrected).
	oso=hsi_obs_summary()
	oso->set,obs_time_interval=obs_time_intv
	osrates=(oso->getdata()).COUNTRATE
	ostimes=oso->getdata(/xaxis)
	OBJ_DESTROY,oso
	IF N_ELEMENTS(osrates) EQ 1 THEN osrates=1+FLTARR(N_ELEMENTS(ostimes),9)
;get TRACE all-FOV lightcurve...
	FOV=-1
	trace_FOV=-1
	bad_ss='asd'
	FOR i=0L,N_ELEMENTS(mainfiles)-1 DO BEGIN
		fits2map,mainfiles[i],mainmap		
		IF datatype(mainmap) EQ 'STC' THEN BEGIN
			addtracelc=TOTAL(SMOOTH(mainmap.DATA,5))	
				;sub_map,mainmap,smap,xrange=xrange,yrange=yrange
				;addtracelc=TOTAL(SMOOTH(smap.DATA,5))	
			IF i EQ 0 THEN tracetimes=anytim(mainmap.time) ELSE tracetimes=[tracetimes,anytim(mainmap.time)]
			IF i EQ 0 THEN tracelc=addtracelc ELSE tracelc=[tracelc,addtracelc]

		;check whether TRACE and HESSI have overlapping FOV at any point:
		trace_FOV=[[mainmap.xc+mainmap.dx*N_ELEMENTS(mainmap.data[*,0])*[-0.5,0.5]],[mainmap.yc+mainmap.dy*N_ELEMENTS(mainmap.data[0,*])*[-0.5,0.5]]]
		IF (has_overlap(hessi_FOV[*,0],trace_FOV[*,0]) AND has_overlap(hessi_FOV[*,1],trace_FOV[*,1])) THEN FOV=hessi_FOV		
		ENDIF ELSE BEGIN
			IF datatype(bad_ss) EQ 'STR' THEN bad_ss=i ELSE bad_ss=[bad_ss,i]
		ENDELSE
	ENDFOR
IF datatype(bad_ss) NE 'STR' THEN mainfiles=array_delete(mainfiles,bad_ss)

;decision on FOV to use...
	IF N_ELEMENTS(FOV) EQ 1 THEN BEGIN
		IF N_ELEMENTS(trace_FOV) GT 1 THEN BEGIN
			xrange=trace_FOV[*,0]
			yrange=trace_FOV[*,1]
		ENDIF ELSE BEGIN
			xrange=[-1000,1000]
			yrange=[-1000,1000]
		ENDELSE
			;I'd rather use the TRACE FOV..., for each TRACE image... (in case the telescope jumps around the Sun...)
	ENDIF ELSE BEGIN
		xrange=FOV[*,0]
		yrange=FOV[*,1]
	ENDELSE

;main business...
	psh_win,2*basesize,basesize
	ctrl=mrdfits(hessifile,1)

	cube='bla'
	cur_t=anytim(obs_time_intv[0])
	cur_frame_nbr=1
	WHILE cur_t LE anytim(obs_time_intv[1]) DO BEGIN
		;Check TRACE & HESSI image usability
		tss=where_nearest(tracetimes,cur_t)
		traceOK=1	;IF abs(tracetimes[tss] - cur_t) LE max_time_diff THEN traceOK=1 ELSE traceOK=0
		hss=where_nearest(hessitimes,cur_t)				
		IF abs(hessitimes[hss] - cur_t) LE max_time_diff THEN hessiOK=1 ELSE hessiOK=0

		;IF NOT (traceOK AND hessiOK) THEN BREAK	;don't add frames were no images are available...

	;plotting images
		!P.MULTI=[0,2,1]
		fits2map,mainfiles[tss],mainmap

		IF KEYWORD_SET(EIT) THEN BEGIN
			IF EIT GE 2 THEN BEGIN
				eit_prep,mainfiles[tss],outheader,outimage,/no_calibrate	;,/no_index,/no_roll
				index2map,outheader,outimage,mainmap
			ENDIF
		ENDIF
		IF mainmap.ROLL_ANGLE eq -180. THEN BEGIN
			PRINT,'.......psh_trace_hessi_movie_make_cube.pro: ROLL_ANGLE is -180! Suspect problem. Putting it to 0...'
			mainmap.ROLL_ANGLE=0
			ROLL_ANGLE_PROBLEM=1
		ENDIF
		mainmap=map2earth(mainmap)

		IF KEYWORD_SET(drange) THEN BEGIN
			DMIN=MIN(mainmap.DATA)+drange[0]*(MAX(mainmap.DATA)-MIN(mainmap.DATA))
			DMAX=MIN(mainmap.DATA)+drange[1]*(MAX(mainmap.DATA)-MIN(mainmap.DATA))
		ENDIF ELSE BEGIN
			DMIN=MIN(mainmap.DATA)
			DMAX=MAX(mainmap.DATA)
		ENDELSE

		IF traceOK THEN plot_map,mainmap,bottom=8,/LOG,xrange=xrange,yrange=yrange,xtitle='',ytitle='',grid=10,/LIMB,xmar=[5,0],ymar=[2,2],/ISO,charsize=charsize,DMIN=DMIN,DMAX=DMAX $
		ELSE plot_map,{data:dist(100),xc:0,yc:0,dx:20,dy:20,xunits:'arcsecs',yunits:'arcsecs',id:'dummy', time: 'dummy'},xrange=xrange,yrange=yrange,grid=10,/LIMB,xmar=[5,0],ymar=[2,2],/ISO,charsize=charsize,/NODATA,title=anytim(cur_t,/ECS)+' UT'
		
		IF exist(ROLL_ANGLE_PROBLEM) THEN label_plot,/RIGHT,0.95,-1.2,'ROLL_ANGLE=-180->0'
		
		IF hessiOK THEN BEGIN
			FOR j=0,n_ebands_ss-1 DO BEGIN
				info=mrdfits(hessifile,hss*n_ebands+ebands_ss[j]+1,status=fstatus)
				IF fstatus GE 0 THEN nbr_counts=rhessi_img_counts(info,ctrl) ELSE nbr_counts=999999999L
				IF KEYWORD_SET(min_nbr_counts) THEN IF nbr_counts LT min_nbr_counts THEN BREAK				
				plot_map,*hessimapptr[ebands_ss[j],hss],/OVER,lcolor=j+1+(j GE 4),/percent,level=[50,101]	;level=[20,50,80,101]
				label_plot,0.03,-j-1,strn(FIX(ebands[0,ebands_ss[j]]))+'-'+strn(FIX(ebands[1,ebands_ss[j]]))+' keV',color=j+1+(j GE 4)
				label_plot,0.03,n_ebands_ss-j,strn(LONG(nbr_counts)),color=j+1+(j GE 4)
			ENDFOR;j
		ENDIF

	;plotting lightcurves/spg...
		!P.MULTI=[2,2,2,0,1]
		clear_utplot

		utplot,ostimes,TOTAL(osrates[0:1,*],1),timerange=obs_time_intv,color=1,ytit='Cts/s/det',/YLOG,yr=[1,10000],xtit='',xstyle=1,xmar=[8,1],ymar=[2,1],charsize=charsize
		outplot,ostimes,osrates[2,*],color=2
		outplot,ostimes,TOTAL(osrates[3:4,*],1),color=3
		outplot,ostimes,TOTAL(osrates[5:*,*],1),color=5
		
		plot_label,/NOLINE,/DEV,[0.03,-1],'3-12 keV',color=1,charsize=charsize
		plot_label,/NOLINE,/DEV,[0.03,-2],'12-25 keV',color=2,charsize=charsize
		plot_label,/NOLINE,/DEV,[0.03,-3],'25-100 keV',color=3,charsize=charsize
		plot_label,/NOLINE,/DEV,[0.03,-4],'0.1-17 MeV',color=5,charsize=charsize
		label_plot,0.975,-1.1,/RIGHT,'RHESSI'
		
		;adding HESSI accum. times boundaries...
		IF hessiOK THEN BEGIN
			PLOTS,/DATA,[1,1]*hessi_tintvs[0,hss],[1,10000],linestyle=2
			PLOTS,/DATA,[1,1]*hessi_tintvs[1,hss],[1,10000],linestyle=2
		ENDIF
	
		;adding TRACE lc & boundaries...
		utplot,tracetimes,tracelc,timerange=obs_time_intv,color=4,ytit='DN',xtit='',xstyle=1,xmar=[8,1],ymar=[2,1],charsize=charsize,psym=-7,yr=minmax(tracelc)*[0.9,1.1],ystyle=1	;,/YLOG
		IF !Y.TYPE EQ 0 THEN traceminmax=!Y.CRANGE ELSE traceminmax=10^!Y.CRANGE
		IF traceOK THEN BEGIN
			PLOTS,/DATA,[1,1]*anytim(mainmap.time)-0.5*mainmap.dur,traceminmax,linestyle=2
			PLOTS,/DATA,[1,1]*anytim(mainmap.time)+0.5*mainmap.dur,traceminmax,linestyle=2		
		ENDIF ELSE PLOT,FINDGEN(10),/NODATA
		IF KEYWORD_SET(EIT) THEN label_plot,0.975,-2,/RIGHT,'EIT' ELSE label_plot,0.975,-2,/RIGHT,'TRACE' 
		label_plot,0.975,1.3,/RIGHT,STRN(cur_frame_nbr)

		IF datatype(cube) EQ 'STR' THEN cube=TVRD() ELSE cube=[[[cube]],[[TVRD()]]]
		cur_t=cur_t+dt
		cur_frame_nbr=cur_frame_nbr+1
		PRINT,'Completed: '+strn(100.*(cur_t-anytim(obs_time_intv[0]))/(anytim(obs_time_intv[1])-anytim(obs_time_intv[0])),format='(f10.1)')+' %'
	ENDWHILE
RETURN,cube
END

