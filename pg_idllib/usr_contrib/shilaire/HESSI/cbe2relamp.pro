;calibrated event list to relative amplitudes
;
;	Rel. Amplitude = A = (Cmax-<C>)/<C>/M, where M is the maximum modulation amplitude.
;
;This routine will draw the cbe. With left clicks, enter successive Cmax/Cmin. Rigth-click to end.
;The procedure will write the Relative Amplitude, with the 1-sigma error.
;



PRO cbe2relamp,cbe,coll=coll,harmonic=harmonic,timerange=timerange,SMOOTHE=SMOOTHE,	$
		RelAmp_mean=RelAmp_mean,RelAmp_sigma=RelAmp_sigma

	IF NOT KEYWORD_SET(coll) THEN coll=0
	IF NOT KEYWORD_SET(harmonic) THEN harmonic=0
	
	times=DOUBLE((*cbe[coll,harmonic]).time)/2.^20.
	counts=(*cbe[coll,harmonic]).count
	livetime=(*cbe[coll,harmonic]).livetime
	ss=WHERE(livetime NE 0.)
	counts[ss]=counts[ss]/livetime[ss]

	IF KEYWORD_SET(SMOOTHE) THEN counts=SMOOTH(counts,SMOOTHE)
	modamp=(*cbe[coll,harmonic]).modamp

	!P.MULTI=0
	utplot,times,counts,tit='calibrated eventlist, corrected for livetime',charsize=1.5,timerange=timerange

	;GET modulations, until a right-click is issued.
	
	nmod=0
	RelAmp=-1

	!mouse.button=0
	WHILE (!mouse.button NE 4) DO BEGIN

		PRINT,''
		PRINT,'Enter Cmax/Cmin (left-click) or cancel last Cmax/Cmin entry (middle-click), or end (right-click).'
		PRINT,'Number of entries: '+strn(nmod)
		CURSOR,x,y,/data,/down

		IF (!mouse.button EQ 1) THEN BEGIN
			nmod=nmod+1
			xmax=x
			ymax=y
			ss=WHERE(times GE xmax)
			ss=ss[0]
			Mmax=modamp[ss]
			PRINT,'Time: '+strn(xmax)+'   Cmax: '+strn(ymax)+'    M='+strn(Mmax)
			PRINT,'Now, enter Cmin:'
			CURSOR,x,y,/data,/down
			xmin=x
			ymin=y
			ss=WHERE(times GE xmin)
			ss=ss[0]
			Mmin=modamp[ss]
			PRINT,'Time: '+strn(xmin)+'   Cmin: '+strn(ymin)+'    M='+strn(Mmin)

			Mavg=(Mmax+Mmin)/2.
			tmp=(ymax-ymin)/(ymax+ymin)/Mavg			
			IF RelAmp[0] EQ -1 THEN RelAmp=tmp ELSE RelAmp=[RelAmp,tmp]
			PRINT,'Last entry had relative modulated flux of: '+strn(tmp)		
		ENDIF

		IF (!mouse.button EQ 2) THEN BEGIN
			IF nmod NE 0 THEN nmod=nmod-1
			IF nmod EQ 0 THEN RelAmp=-1 ELSE RelAmp=RelAmp[0:nmod-1]
		ENDIF
	ENDWHILE

	IF nmod EQ 0 THEN BEGIN PRINT,'No entries!' & RETURN & ENDIF
	
	RelAmp_mean=MEAN(RelAmp)
	RelAmp_sigma=STDDEV(RelAmp)
	
	PRINT,''
	PRINT,'MEAN: '+strn(RelAmp_mean)
	PRINT,'SIGMA: '+strn(RelAmp_sigma)

END
