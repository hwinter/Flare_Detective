;counts_percoll is per time bins

FUNCTION hedc_determine_img_times,MINNBRCOUNTS,imgalg,taxis,ss_beg,ss_end,counts_percoll
	MAXACCTIME=60.
	
	i=ss_beg
	WHILE i LE ss_end DO BEGIN
		curi=i
		cumtot=0L
		WHILE cumtot LE MINNBRCOUNTS DO BEGIN
			i=i+1
			cumtot=cumtot+counts_percoll[i]
			IF i GE ss_end THEN BEGIN
				IF NOT EXIST(tim) THEN RETURN,[taxis(curi),taxis(i)] ELSE RETURN,[[tim],[taxis(curi),taxis(i)]]	
			ENDIF
		ENDWHILE
		newtim=anytim([taxis(curi),taxis(i)])
		IF (newtim(1)-newtim(0)) GT MAXACCTIME THEN newtim=(newtim(0)+newtim(1))/2. + MAXACCTIME*[-0.5,0.5]
		IF NOT EXIST(tim) THEN tim=newtim ELSE tim=[[tim],[newtim]]
	ENDWHILE
END
