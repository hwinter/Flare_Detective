;============================================================================
;+
; NAME:  rapp_dbbuild.pro
;
; PURPOSE:  creates/updates rag bursts dbase from bl.txt file
;
; CALLING SEQUENCE: 
;
; INPUTS:
;
; KEYWORD INPUT:
;
; OUTPUTS:  
;
; OPTIONAL OUTPUTS:  
;
; Calls:
;	ssw/gen/database procedures
;
; COMMON BLOCKS: None
;
; PROCEDURE:
;
; RESTRICTIONS:
;
; SIDE EFFECTS:
;
; EXAMPLES:
;
; HISTORY:
;       Written Pascal Saint-Hilaire, 2002/01/04.
;			shilaire@astro.phys.ethz.ch OR psainth@hotmail.com
; MODIFICATIONS:
;
;-
;===========================================================================================
;===========================================================================================
pro fakedb,b_start,b_end,b_type,b_feature,b_intensity,b_quality,b_sfrq,b_efrq,b_com,b_fil
b_start=[1000.1D,2000.2D,3000.3D]
b_end=[1001.1D,2002.2D,3003.3D]
b_type=['I','DCIM','bek']
b_feature=[['','','','',''],['a','b','c','',''],['b','e','g','c','a']]
b_intensity=[3,2,1]
b_quality=[1,2,3]
b_sfrq=[0L,200L,400L]
b_efrq=[300L,99999L,450L]
b_com=['','areuh!','blabla']
b_fil=['fil1','fil2','fil3']
END
;===========================================================================================
pro read_burstlist,b_start,b_end,b_type,b_feature,b_intensity,b_quality,b_sfrq,b_efrq,b_com,b_fil,$
	file=file

IF NOT KEYWORD_SET(file) THEN file='/global/helene/data/rag/junk/burst/bl.txt'

MAX_NBR_FEATURES=5	; this is in the dbase schema (.dbd file)...

b_start=1D
b_end=1D
b_type='bla'
b_feature=['','','','','']
b_intensity=0
b_quality=0
b_sfrq=200L
b_efrq=550L
b_com='bla'
b_fil='bla'

;1) read every line of bl.txt.
;2) check whether line is OK.
;3) add new values to b_... vectors.

OPENR,lun,file,/GET_LUN

ligne='bla'
for i=0,3 do READF,lun,ligne	; go through all headers...

tmp_first=1
hedc_add_to_log,'Problem bursts:',dir='/global/hercules/users/shilaire/LOGS/RAPPdbase',file='bad.log',/new

WHILE NOT EOF(lun) DO BEGIN
	;catch statement for each line...
	error_status=0
	CATCH, error_status
		IF error_status NE 0 then begin
			print,'PROBLEMS with the following line: '
			print,ligne
			PRINT, 'Error index: ', Error_status
			PRINT, 'Error message: ', !ERROR_STATE.MSG
			print,'............. it has been skipped.'
			hedc_add_to_log,ligne,dir='/global/hercules/users/shilaire/LOGS/RAPPdbase',file='bad.log'
			GOTO,NEXTPLEASE		
		endif
	
	tmp_start=-9999.0D
	tmp_end=-9999.0D
	tmp_type='-9999'
	tmp_feature=['-9999','-9999','-9999','-9999','-9999']
	tmp_intensity=-9999
	tmp_quality=-9999
	tmp_sfrq=-9999L
	tmp_efrq=-9999L
	tmp_com=''
	tmp_fil=''

	ligne='bla'
	READF,lun,ligne
	choses=rsi_strsplit(ligne,/EXTRACT)
	if n_elements(choses) gt 3 then begin
		tmp=choses(0)+' '+STRMID(choses(3),0,2)+':'+STRMID(choses(3),2,2)+':00'
		tmp_start=anytim(tmp)+60.*DOUBLE(STRMID(choses(3),5,2))
		tmp=choses(0)+' '+STRMID(choses(4),0,2)+':'+STRMID(choses(4),2,2)+':00'
		tmp_end=anytim(tmp)+60.*DOUBLE(STRMID(choses(4),5,2))
		tmp_type=choses(5)
		posi=6
		; now, is choses(posi) a feature or already intensity ?
		if is_number(choses(posi)) then begin
			tmp_feature=['','','','','']			
		endif else begin
			tmp_feature=rsi_strsplit(choses(posi),',',/EXTRACT)
			i=MAX_NBR_FEATURES-n_elements(tmp_feature)
			if i gt 0 then begin
				while i gt 0 do begin
					tmp_feature=[tmp_feature,'']
					i=i-1
				endwhile
			endif
			posi=7
		endelse
		tmp_intensity=FIX(choses(posi))
		; now, freqs:
		if stregex(choses(posi+1),'X|x',/BOOLEAN) then tmp_sfrq=0L else tmp_sfrq=LONG(choses(posi+1))
		if stregex(choses(posi+2),'X|x',/BOOLEAN) then tmp_efrq=999999L else tmp_efrq=LONG(choses(posi+2))
		tmp_quality=FIX(choses(posi+3))		
		;for the rest, everything which starts with a number is a file name, otherwise a comment
		if n_elements(choses) gt posi+4 then begin
			for i=posi+4,n_elements(choses)-1 do begin
				if (stregex(choses(i),'.fit',/BOOLEAN) OR (is_number(choses(i)) AND (strlen(choses(i)) EQ 1))) then tmp_fil=tmp_fil+choses(i)+' ' $
				else tmp_com=tmp_com+choses(i)+' '
			endfor
		endif

		;create/update vectors
		if tmp_first eq 1 then begin
			b_start=tmp_start
			b_end=tmp_end
			b_type=tmp_type
			b_feature=tmp_feature
			b_intensity=tmp_intensity
			b_quality=tmp_quality
			b_sfrq=tmp_sfrq
			b_efrq=tmp_efrq
			b_com=tmp_com
			b_fil=tmp_fil

			tmp_first=0
		endif else begin 
			b_start=[b_start,tmp_start]
			b_end=[b_end,tmp_end]
			b_type=[b_type,tmp_type]
			b_feature=[b_feature,tmp_feature]
			b_intensity=[b_intensity,tmp_intensity]
			b_quality=[b_quality,tmp_quality]
			b_sfrq=[b_sfrq,tmp_sfrq]
			b_efrq=[b_efrq,tmp_efrq]
			b_com=[b_com,tmp_com]
			b_fil=[b_fil,tmp_fil]
									
		endelse	
	endif
	NEXTPLEASE:
	CATCH,/CANCEL
ENDWHILE

;print,'FINISHED with read_burstlist.pro, without break errors.'
FREE_LUN,lun
END
;=============================MAIN==========================================================
pro rapp_dbbuild

dbname='rapp'
;oldzdbase='/global/helene/local/ssw/soho/gen/data/plan/database'
setenv,'ZDBASE=/global/hercules/users/shilaire/RAPPdbase'
!PRIV=2	;so I'm allowed to construct dbase

dbcreate,getlog('ZDBASE')+'rapp',1,1
dbopen,'rapp',1
;fakedb,b_start,b_end,b_type,b_feature,b_intensity,b_quality,b_sfrq,b_efrq,b_com,b_fil
read_burstlist,b_start,b_end,b_type,b_feature,b_intensity,b_quality,b_sfrq,b_efrq,b_com,b_fil
dbbuild,b_start,b_end,b_type,b_feature,b_intensity,b_quality,b_sfrq,b_efrq,b_com,b_fil
dbclose

!PRIV=0	;to prevent any more fiddling with dbase.
print,'FINISHED with rapp_dbbuild, without break errors.'
END
;==============================MAIN END=====================================================


