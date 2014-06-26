;	PSH, 2002/11/25
;	
; 	'anytime' can be a single time, or a time interval (ANYTIM format in both cases)
;
;
; EXAMPLE:
;	nrh_map=get_nrh_map('/global/hercules/data3/users/shilaire/HXR_DCIM/2001_06_15/nrh/2i010615.01',freq=2,'12:05:00')
;


FUNCTION get_nrh_map, nrhfile, anytime, FREQ=freq, V=V, NPIXELS=npixels

	IF NOT KEYWORD_SET(FREQ) THEN freq=0
	IF NOT KEYWORD_SET(NPIXELS) THEN npixels=128
	
	frq_arr=[164.,236.6,327.,410.5,432.]
	break_file,nrhfile, DISK_LOG, DIR, FILNAM, EXT, FVERSION, NODE
	
	PRINT,'.........Time: '+anytim(anytime,/time,/ECS)
	IF NOT KEYWORD_SET(V) THEN PRINT,'..........Stokes I' ELSE PRINT,'..........Stokes V'
	PRINT,'........ Frequency: '+strn(frq_arr[freq],format='(f7.1)')+' MHz.'
	PRINT,'.........Image size: '+strn(npixels)+' pixels.'

	hbeg=anytim(anytime[0],/time,/ECS)
	IF N_ELEMENTS(anytime) GT 1 THEN hend=anytim(anytime[1],/time,/ECS) ELSE hend=hbeg

	IF npixels EQ 128 THEN read_nrh,FILNAM+EXT,index,data,dir=DIR,freq=freq,hbeg=hbeg,hend=hend,STOKES=V $
	ELSE modified_read_nrh,FILNAM+EXT,index,data,dir=DIR,freq=freq,size=npixels,hbeg=hbeg,hend=hend,STOKES=V

	index2map,index,data,nrhmap

RETURN, nrhmap
END
