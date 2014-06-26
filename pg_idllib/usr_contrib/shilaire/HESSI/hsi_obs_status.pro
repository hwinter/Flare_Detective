; a tiny routine that checks Hessi's status
; given an ANYTIM time interval...
;
; ONLY ONE of the following keywords may be set at a time:
;	/SUN,/SAA,/NIGHT
;
; interval : returns actual array of intervals in SUN/SAA/NIGHT with overlap with
;	input time_intv,  in ANYTIM double format.
;
;	RETURNS 1 IF THE FLAG CHECKED FOR IS TRUE AT LEAST ONCE IN THE INTERVAL.
;	RETURNS 0 IF THE FLAG CHECKED FOR IS ALWAYS FALSE IN THE INTERVAL.
;	RETURNS -1 IF AN ERROR OCCURED (i.e. no files, etc...)
;
; EXAMPLE:
;	res=hsi_obs_status('2002/02/20 '+['09:00:00','22:00:00'],/night,interval=intv)
;	print,res
;	print,anytim(intv,/ECS)
;
;
;
;LATER: if file not in our local file system, should retrieve it...
;




;=======================================================================================================
FUNCTION hsi_obs_status, time_intv, dir=dir,sun=sun, saa=saa, night=night, $
	interval=interval,LOUD=LOUD

IF KEYWORD_SET(SUN) THEN SUN=1 ELSE SUN=0	
IF KEYWORD_SET(SAA) THEN SAA=1 ELSE SAA=0
IF KEYWORD_SET(NIGHT) THEN NIGHT=1 ELSE NIGHT=0
IF NOT KEYWORD_SET(dir) THEN dir='/global/hercules/data1/hessi/obs_times/'

IF (SUN+SAA+NIGHT) ne 1 THEN BEGIN
	PRINT,'Improper use of get_hsi_status.pro !!! : only /SUN is assumed...'
	SUN=1
	SAA=0
	NIGHT=0
ENDIF

;initialize optional keyword output:
interval='NULL'

; NOW, choose the right file to read, according to the time_intv given...
	dumbformat=ut_2_yydoy(time_intv)
	list=-1
;;;;	filelist=dir+'HESSI_'+['02037','02051','02065','02080','02094','02108','02122']+'_DUREVT.'+['04','01','01','00','00','01','01']
	filelist=FINDFILE(dir+'*')
	
;NOW, get all lines with a possible amatch with the ddd/yy token.
	amatch=int2str(LONG(dumbformat[1]),3)+'/'+int2str(LONG(dumbformat(0)),2)
	IF KEYWORD_SET(LOUD) THEN PRINT,amatch
	FOR i=0L,N_ELEMENTS(filelist)-1 DO BEGIN 
		alllines=rd_text(filelist[i])
		tmp=grep('Sunlight',alllines,index=index)
		sunline=index[0]
		tmp=grep('Eclipse',alllines,index=index)
		nightline=index[0]
		tmp=grep('South-Atlantic-Anomaly',alllines,index=index)
		saaline=index[0]
		
		IF SUN THEN lines=alllines[sunline:nightline]
		IF NIGHT THEN lines=alllines[nightline:saaline]
		IF SAA THEN lines=alllines[saaline:*]
		
		newlist=grep(amatch,lines)		
		IF (newlist[0] ne '') THEN IF DATATYPE(list) eq 'INT' THEN list=grep(amatch,lines) ELSE list=[list,grep(amatch,lines)]
	ENDFOR
	
IF datatype(list) EQ 'INT' THEN RETURN,-1	; not the right file(s), obviously...

;NOW, perform interval checks...
FOR i=0L,N_ELEMENTS(list)-1 DO BEGIN
	tmp1=rsi_strsplit(list(i),',',/EXTRACT) ;tmp1(0) is the start time
	tmp2=rsi_strsplit(tmp1(0),' ',/EXTRACT)	;tmp2(0) is the start doy/yy
	tmp3=rsi_strsplit(tmp2(0),'/',/EXTRACT)
	yydoy=[DOUBLE(tmp3(1)),DOUBLE(tmp3(0))]
	starttime=yydoy_2_ut(yydoy)+anytim(tmp2(1),/time)

	tmp2=rsi_strsplit(tmp1(2),' ',/EXTRACT)	;tmp2(0) is the start doy/yy
	tmp3=rsi_strsplit(tmp2(0),'/',/EXTRACT)
	yydoy=[DOUBLE(tmp3(1)),DOUBLE(tmp3(0))]
	endtime=yydoy_2_ut(yydoy)+anytim(tmp2(1),/time)
	
	IF has_overlap([starttime,endtime],time_intv) THEN BEGIN
		IF datatype(interval) EQ 'STR' THEN interval=[starttime,endtime] ELSE interval=[[interval],[starttime,endtime]]
	ENDIF	
ENDFOR

IF datatype(interval) NE 'STR' THEN RETURN,1 ELSE RETURN,0
END
