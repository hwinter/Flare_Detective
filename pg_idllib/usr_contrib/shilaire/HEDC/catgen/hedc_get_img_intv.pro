;+
;
; to_nice_img_intervals.pro does "most" of the work, i.e. finds time intervals suitable for imaging.
;	This routine actually cuts'em up in smaller pieces suitable for imaging time_range.
;
; This routine will return a list of time_ranges GOOD for ONE image.
; If a time interval does not have enough counts, won't allow it.
; If that would mean NO allowable time ranges, then one with the most counts is returned
; Better to give FLARE time interval (i.e. no useless background time)
;
; eband can is list of Obs. Summ. energy bands to check
; If keyword maxintv is used, will return only that number of intervals (if possible, spaced evenly
; among the available intervals).
;
; if maxaccumtime is specified (in seconds), time segments will be limited to this value
; if backgnd_intv is specified, then counts ABOVE background levels will be considered. 
;       CAREFUL HERE: Maybe I should not use it, whenever we have varying attenuator/decimation states.
;	We definately need properly background-subtracted lightcurves, with background corrected appropriately
;	in EACH TIME BIN for bin's attenuator/decimation states.
;
;
; all returned time intervals are sorted by ascending time.
; output keyword mostcounts gives ss of interval with most counts
;
; a -1 is returned if absolutely nothing is suitable for imaging.
; 
; maxaccumtime and minaccumtime take precedence over counts per time bin, if it is an issue.
;
;EXAMPLE:
;	
;	intvs=hedc_get_img_intv(flare_time_interval)
;
;	time_intv='2002/02/26 '+['10:25:00','10:35:00']
;	backgndtime='2002/02/26 '+['10:24:00','10:25:00']
;	eband=[0,1]	;2
;	intvs=hedc_get_img_intv(time_intv,nbrcounts=MINNBRCOUNTSPERCOLL, eband=eband, maxaccumtime=32.1,maxintv=5,backgnd_intv=backgndtime)
;	PRINT,anytim(intvs,/ECS)
;
;
; MODIFICATIONS
;	2002/11/14: added keyword /ATTLOW in call to to_nice_img_intervals.pro
;	2002/12/09: uses corrected counts, when Obs. Summ. data is available !!!! Added keyword minaccumtime.
;	2003/01/10: if max_intv is used, now makes a better selection on intervals...
;
;-

FUNCTION hedc_get_img_intv, time_intv, minaccumtime=minaccumtime,	$
	nbrcounts=nbrcounts, eband=eband, maxaccumtime=maxaccumtime,maxintv=maxintv,backgnd_intv=backgnd_intv,peaktime=peaktime
	
	IF NOT KEYWORD_SET(nbrcounts) THEN nbrcounts=5000L
	IF NOT KEYWORD_SET(eband) THEN eband=2	; could be[1,2,3] for 6-50 keV range...
	IF NOT KEYWORD_SET(minaccumtime) THEN minaccumtime=0.
	
	good_time_intvs=to_nice_img_intervals(time_intv,eband=eband,mostcounts=most_counts_intv_ss,counts=countsarray,/ATTLOW,mindeltat=minaccumtime)
	;good_time_intvs=to_nice_img_intervals(time_intv,eband=eband,mostcounts=most_counts_intv_ss,counts=countsarray,/ATTLOW,mindeltat=minaccumtime,/PARTICLES,wait_after_shutter=60.,wait_after_eclipse=120.)
	;Now I have a list of time intervals appropriate for imaging (no SAA/NIGHT, no change in attenuator states, etc...),
	; and having at least 'nbrcounts'. Now, one only has to chop'em up in smaller imaging segments of nbrcounts.
	IF N_ELEMENTS(good_time_intvs) EQ 1 THEN RETURN,-1	; no good intervals!
	
	oso=hsi_obs_summary()
	oso->set,obs_time_interval=time_intv
	rates_struct=oso->getdata()

; get RATES.......
IF datatype(rates_struct) EQ 'INT' THEN BEGIN
	PRINT,'.......... looks like there are no Obs. Summ. for this period.... assuming need to get count rates from lightcurve object...this is going to be lenghty!'
	lco=hsi_lightcurve()
	lco->set,time_range=time_intv
	time_bin=4.
	lco->set,ltc_time_res=time_bin,SEG_INDEX=BYTARR(18)+1B
	energyedges=[3,6,12,25,50,100,300,800,7000,20000]
	rates='bla'
	FOR ii=0,8 DO BEGIN
		lco->set,ltc_energy_band=[energyedges[ii],energyedges[ii+1]]
		lc=lco->getdata()
		IF datatype(rates) EQ 'STR' THEN rates=lc ELSE rates=[[rates],[lc]]
	ENDFOR
	times=lco->getdata(/xaxis)	
	most_counts_intv_ss=0
	IF KEYWORD_SET(backgnd_intv) THEN BEGIN
		lco->set,time_range=backgnd_intv
		backrates='bla'
		FOR ii=0,8 DO BEGIN
			lco->set,ltc_energy_band=[energyedges[ii],energyedges[ii+1]]
			lc=lco->getdata()
			IF datatype(backrates) EQ 'STR' THEN backrates=lc ELSE backrates=[[backrates],[lc]]
		ENDFOR
		back_lvl=avg(backrates,0)
		FOR i=0,N_ELEMENTS(back_lvl)-1 DO rates[*,i]=rates[*,i]-back_lvl[i]
	ENDIF
	OBJ_DESTROY,lco	
	rates=TRANSPOSE(rates)/time_bin/9.
ENDIF ELSE BEGIN
	rates=rates_struct.COUNTRATE
	IF datatype(rates) EQ 'BYT' THEN BEGIN
		PRINT,'.............oups! A screw up (again!): apparently, I need to decompress those #%$@ rates.... decompressing now....'
		rates=hsi_obs_summ_decompress(rates_struct.COUNTRATE)
	ENDIF
	times=oso->getdata(/time)
	info=oso->get(class_name='hsi_obs_summ_rate')
	time_bin=info.time_intv
	IF KEYWORD_SET(backgnd_intv) THEN BEGIN
		oso->set,obs_time_interval=backgnd_intv
		backrates_struct=oso->getdata()
		backrates=backrates_struct.COUNTRATE
		IF datatype(backrates) EQ 'BYT' THEN backrates=hsi_obs_summ_decompress(backrates_struct.COUNTRATE)
		back_lvl=avg(backrates,1)
		FOR i=0,N_ELEMENTS(back_lvl)-1 DO rates[i,*]=rates[i,*]-back_lvl[i]
	ENDIF
	OBJ_DESTROY,oso
;;2002/12/09: the above 16 lines have been replaced by the following:
;	rates=hessi_corrected_os_countrate(time_intv,time=times)
;	time_bin=times[1]-times[0]
;	IF KEYWORD_SET(backgnd_intv) THEN BEGIN
;		backrates=hessi_corrected_os_countrate(backgnd_intv)
;		back_lvl=avg(backrates,1)
;		FOR i=0,N_ELEMENTS(back_lvl)-1 DO rates[i,*]=rates[i,*]-back_lvl[i]	
;	ENDIF
ENDELSE
	
	
;----------------------------------------------------------------------	
	
	;FOR EACH good_time_intv, subdivide into minimal imaging intervals
	FOR i=0,N_ELEMENTS(good_time_intvs[0,*])-1 DO BEGIN
		tmp=WHERE(times GE good_time_intvs[0,i])
		ss_start=tmp[0]
		tmp=WHERE(times GE good_time_intvs[1,i])
		ss_end=tmp[0]
		
		j=ss_start
		WHILE j LE ss_end DO BEGIN
			curj=j
			cumtot=0L
			goon=1
			WHILE goon DO BEGIN
				ctsforcurrentbin=0L
				FOR k=0,N_ELEMENTS(eband)-1 DO ctsforcurrentbin=ctsforcurrentbin+rates[eband[k],j]*time_bin
				cumtot=cumtot+ctsforcurrentbin				
				IF j GE (ss_end-1) THEN BREAK
				j=j+1
				IF KEYWORD_SET(maxaccumtime) THEN IF (j-curj)*time_bin GT maxaccumtime THEN BREAK
				IF (j-curj)*time_bin LT minaccumtime THEN goon=1 ELSE goon=0
				IF cumtot LT nbrcounts THEN goon=1				
			ENDWHILE		
			IF (j-curj)*time_bin GE minaccumtime THEN BEGIN			
				newtim=[times[curj],times[j]]
				IF NOT EXIST(tim) THEN tim=newtim ELSE tim=[[tim],[newtim]]
			ENDIF
			j=j+1
		ENDWHILE
	ENDFOR




	IF exist(tim) THEN BEGIN
		IF KEYWORD_SET(maxintv) THEN BEGIN
			n_tim=N_ELEMENTS(tim[0,*])
			IF n_tim GT maxintv THEN BEGIN
				IF NOT KEYWORD_SET(peaktime) THEN tim=tim[*,FIX(FINDGEN(maxintv)*n_tim/maxintv)] ELSE BEGIN
					;;---------1)find intv closest to PEAK_TIME, use it for first picture.
					mid_intv_tims=(anytim(tim[0,*])+anytim(tim[1,*]))/2.
					dist_to_peaktim=abs(mid_intv_tims-anytim(peaktime))
					tmp=MIN(dist_to_peaktim,peak_intv_ss)
					tim2=tim[*,peak_intv_ss]
					;;---------2)if max_intv >1, then take 1 or more intv before (if any), and 1 or more after (if any).
					IF maxintv GT 1 THEN BEGIN
						;nbr before
						n_before=MIN([CEIL((maxintv-1)/2.),N_ELEMENTS(tim[0,0:peak_intv_ss])-1])
						IF n_before GE 1 THEN add_ss1=FIX(FINDGEN(N_ELEMENTS(tim[0,0:peak_intv_ss])-1)*N_ELEMENTS(n_before)/(N_ELEMENTS(tim[0,0:peak_intv_ss])-1)) ELSE add_ss1=-1
						;nbr after
						n_after=MIN([FLOOR((maxintv-1)/2.),N_ELEMENTS(tim[0,peak_intv_ss:*])-1])
						IF n_after GE 1 THEN add_ss2=peak_intv_ss+1+FIX(FINDGEN(N_ELEMENTS(tim[0,peak_intv_ss:*])-1)*N_ELEMENTS(n_after)/(N_ELEMENTS(tim[0,peak_intv_ss:*])-1)) ELSE add_ss2=-1
						
						ss=UNIQ([add_ss1,peak_intv_ss,add_ss2])
						tim2=tim[*,ss]						
					ENDIF				
				tim=tim2
				ENDELSE	
			ENDIF			
		ENDIF	
		RETURN,tim 	
	ENDIF ELSE BEGIN
		;RETURN,good_time_intvs[*,FIX((N_ELEMENTS(good_time_intvs[0,*])-1)/2)]	; else returns ~middle interval...
		; instead of returning middle one, should return the one with the highest counts in it...
		PRINT,'................ not enough counts in any of the time intervals, or time_intervals too short.'
		PRINT,'.......Returning interval with highest number of counts.'
		tim=anytim(good_time_intvs[*,most_counts_intv_ss])
			;if tmp is bigger than maxaccumtime, then return the proper range
			IF KEYWORD_SET(maxaccumtime) THEN BEGIN
				IF (tim[1]-tim[0]) GT maxaccumtime THEN BEGIN
					;find the peak rate in this eband and time interval, return peak time +/- maxaccumtime/2
					tmp=WHERE(times GE tim[0])
					ss_start=tmp[0]
					tmp=WHERE(times GE tim[1])
					ss_end=tmp[0]
					IF ss_end EQ -1 THEN ss_end=N_ELEMENTS(times)-1
										
					tmp=MAX(TOTAL(rates[[eband],ss_start:ss_end],1),peak_time_ss)
					newtim=times[peak_time_ss]+FLOAT(maxaccumtime)*[-0.5,0.5]
					IF newtim[1] GT tim[1] THEN newtim=newtim-(newtim[1]-tim[1])
					IF newtim[0] LT tim[0] THEN newtim=newtim+(newtim[0]-tim[0])
					tim=newtim
				ENDIF
			ENDIF
		RETURN, tim
	ENDELSE
END


