;+
; t_intvs=hedc_get_relevant_img_intv('2002/04/21 '+['00:00','03:00'], max_nbr=10)
; 
;
;
; FOR i=0L,N_ELEMENTS(t_intvs[0,*])-1 DO POLYFILL,[t_intvs[0,i],t_intvs[1,i],t_intvs[1,i],t_intvs[0,i]]-anytim('2002/04/21 00:00'),[0,0,2000,2000],ORIENTATION=45,/LINE_FILL
;-


FUNCTION hedc_get_relevant_img_intv, flare_intv, SKIP=SKIP, max_nbr_intvs=max_nbr_intvs, deltat=deltat, REDUCE=REDUCE

	IF NOT KEYWORD_SET(deltat) THEN deltat=60.
	
	t_intvs=-1
	good_img_intvs=to_nice_img_intervals(flare_intv,mindeltat=deltat/2.,/ATTLOW,wait_after_shutter=60.,wait_after_eclipse=120.,/REAR_DECIMATION)
		;good_img_intvs=to_nice_img_intervals(flare_intv,mindeltat=deltat/2.,/ATTLOW,/PARTICLES,wait_after_shutter=60.,wait_after_eclipse=120.)
	IF N_ELEMENTS(good_img_intvs) LE 1 THEN MESSAGE,'.......NO GOOD TIME INTV FOUND!'
	good_img_intvs=anytim(good_img_intvs)
	FOR i=0,N_ELEMENTS(good_img_intvs[0,*])-1 DO BEGIN
		duration=good_img_intvs[1,i]-good_img_intvs[0,i]
		n=duration/deltat	;n is a double
		WHILE n GE 1. DO BEGIN
			IF N_ELEMENTS(t_intvs) EQ 1 THEN t_intvs=good_img_intvs[1,i]-[n,n-1]*deltat ELSE t_intvs=[[t_intvs],[good_img_intvs[1,i]-[n,n-1]*deltat]]
			n=n-1.
		ENDWHILE
		IF n GE 0.5 THEN IF N_ELEMENTS(t_intvs) EQ 1 THEN t_intvs=good_img_intvs[1,i]-[n,0]*deltat ELSE t_intvs=[[t_intvs],[good_img_intvs[1,i]-[n,0]*deltat]]			
	ENDFOR
	IF KEYWORD_SET(REDUCE) THEN BEGIN
		n_intvs=N_ELEMENTS(t_intvs[0,*])

		calm_goes_intvs=psh_goes_get_calm_intv(flare_intv, min=3*deltat+1)
		;all "calm intervals" are here at least 3*deltat long.
		IF ( (n_intvs GT 5) AND m_has_overlap(t_intvs,calm_goes_intvs)) THEN BEGIN
			;remove all t_intvs which are ENTIRELY in calm times
			good=BYTARR(n_intvs)+1B
			FOR i=0L, n_intvs-1 DO BEGIN
				IF m_has_overlap(t_intvs[*,i],calm_goes_intvs, inter=inter) THEN BEGIN					
					IF (inter[1,0]-inter[0,0]) EQ (t_intvs[1,i]-t_intvs[0,i]) THEN good[i]=0B
				ENDIF
			ENDFOR
			;;add the middle RHESSI intv corresponding to GOES calm times, for each contiguous calm_intv.
			;tmp=get_ss_changes(good)
			;IF tmp[0] NE -1 THEN BEGIN
			;	good[0]=1B & good[(0+tmp[0])/2]=1B & good[tmp[0]]=1B
			;	FOR i=1L, N_ELEMENTS(tmp)-2 DO BEGIN
			;		good[tmp[i]]=1B & good[(tmp[i]+tmp[i+1])/2]=1B & good[tmp[i+1]]=1B 
			;	ENDFOR
			;	good[tmp[N_ELEMENTS(tmp)-1]]=1B & good[(tmp[N_ELEMENTS(tmp)-1]+n_intvs-1)/2]=1B & good[n_intvs-1]=1B
			;ENDIF ELSE PRINT,'Not reducing...'
			good[0]=1B
			good[n_intvs-1]=1B
			breaks=-1
			FOR i=0L,n_intvs-2 DO BEGIN
				IF t_intvs[1,i] NE t_intvs[0,i+1] THEN BEGIN
					IF breaks[0] EQ -1 THEN breaks=i ELSE breaks=[breaks,i]
				ENDIF
			ENDFOR
			IF breaks[0] EQ -1 THEN good[n_intvs/2]=1B ELSE BEGIN
				good[breaks[0]/2]=1B
				FOR i=0L,N_ELEMENTS(breaks)-2 DO BEGIN					
					good[(breaks[i]+breaks[i+1])/2]=1B
				ENDFOR
				good[(breaks[N_ELEMENTS(breaks)-1]+n_intvs-1)/2]=1B
			ENDELSE
						
			t_intvs=t_intvs[*,WHERE(good NE 0)]
		ENDIF		
	ENDIF

	IF KEYWORD_SET(SKIP) THEN BEGIN	;skipping images only in time-contiguous intervals...
		IF SKIP EQ 1 THEN sf=2 ELSE sf=FIX(SKIP)
		n_intvs=N_ELEMENTS(t_intvs[0,*])
		good=BYTARR(n_intvs)+1B
		;find ss of breaks in t_intvs coverage...
		breaks=-1
		FOR i=0L,n_intvs-2 DO BEGIN
			IF t_intvs[1,i] NE t_intvs[0,i+1] THEN BEGIN
				IF breaks[0] EQ -1 THEN breaks=i ELSE breaks=[breaks,i]
			ENDIF
		ENDFOR
		;now divides by sf the number of images in each TIME-CONTIGUOUS intervals, if there are more than n_min
		n_min=sf	;CEIL(1.5*sf); sf+1; sf+2;...
		IF breaks[0] NE -1 THEN BEGIN
			;IF (breaks[0]+1) GE n_min THEN good[psh_skip(good[0:breaks[0]], sf,/COMPLEMENT)]=0B
			tmp=psh_skip(good[0:breaks[0]], sf,/COMPLEMENT) & IF tmp[0] NE -1 THEN  good[tmp]=0B
			FOR i=1L,N_ELEMENTS(breaks)-1 DO BEGIN
			;	IF (breaks[i]-breaks[i-1]) GE n_min THEN BEGIN
					tmp=psh_skip(good[breaks[i-1]+1:breaks[i]], sf,/COMPLEMENT) & IF tmp[0] NE -1 THEN good[breaks[i-1]+1+tmp]=0B
			;	ENDIF
			ENDFOR
			;IF (n_intvs-breaks[i-1]) GE n_min THEN good[breaks[i-1]+1+psh_skip(good[breaks[i-1]+1:*], sf,/COMPLEMENT)]=0B		
			IF N_ELEMENTS(breaks) GE 2 THEN BEGIN
				 tmp=psh_skip(good[breaks[i-1]+1:*], sf,/COMPLEMENT) & IF tmp[0] NE -1 THEN good[breaks[i-1]+1+tmp]=0B	
			ENDIF
		ENDIF ELSE BEGIN 
			tmp=psh_skip(good, sf,/COMPLEMENT) & IF tmp[0] NE -1 THEN  good[tmp]=0B
		ENDELSE
		t_intvs=t_intvs[*,WHERE(good NE 0)]
	ENDIF

	IF N_ELEMENTS(t_intvs) EQ 1 THEN t_intvs=good_img_intvs
	
	IF KEYWORD_SET(max_nbr_intvs) THEN BEGIN						
		PRINT,'.............hedc_set_relevant_img_intv: max_nbr_intvs= '+strn(max_nbr_intvs)
		sf=2
		ok=N_ELEMENTS(t_intvs[0,*]) LE max_nbr_intvs
		WHILE ok EQ 0 DO BEGIN
			PRINT,'Skip factor: '+strn(sf)
			t_intvs=hedc_get_relevant_img_intv(flare_intv, deltat=deltat, SKIP=sf, REDUCE=REDUCE)
			ok=N_ELEMENTS(t_intvs[0,*]) LE max_nbr_intvs
			sf=sf+1
			IF sf GT 6 THEN ok=-1
		ENDWHILE
		IF ok EQ -1 THEN BEGIN		
			PRINT,'Warning: will remove a lot of images...'
			tmp=DOUBLE(N_ELEMENTS(t_intvs[0,*]))/max_nbr_intvs
			ss=LINDGEN(N_ELEMENTS(t_intvs[0,*]))
			IF tmp GT 1. THEN BEGIN
				ss=ss[UNIQ(LONG(ss/tmp))]
				IF ss[0] NE 0 THEN ss=[0,ss]
				t_intvs=t_intvs[*,ss]
			ENDIF
		ENDIF
	ENDIF
RETURN,t_intvs
END
