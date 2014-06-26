;============================================================================
;+
; NAME:  rapp_dbprint.pro
;
; PURPOSE:  
;	Prints each entries of a burst in a format I like.
;
; CALLING SEQUENCE: 
;	rapp_dbprint,list
; INPUTS:
;
; KEYWORD INPUT:
;	/nocomments
;	/files
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
;       Written Pascal Saint-Hilaire, 2002/01/05.
;			shilaire@astro.phys.ethz.ch OR psainth@hotmail.com
; MODIFICATIONS:
;
;-
;===========================================================================================

pro rapp_dbprint,list,nocommments=nocomments,files=files

itemlist='ENTRY,START_ANYTIM,END_ANYTIM,TYPE,INTENSITY,QUALITY,START_FREQ,END_FREQ,COMMENTS,FILES'
dbext,list,itemlist,v_entry,v_START,v_end,v_type,v_int,v_qual,v_sfrq,v_efrq,v_com,v_fil
itemlist='FEATURES(0),FEATURES(1),FEATURES(2),FEATURES(3),FEATURES(4)'
dbext,list,'FEATURES',v_feat

print,''
print,'======== ETHZ RAPP database ========'
print,''
print,'__#__ ___DATE___ STARTTIME  ENDTIME TYPE I Q __FREQUENCY__ _SPECIAL_______'
for i=0L,n_elements(list)-1 do begin
	ligne=STRING(v_entry(i),format='(I5)')+' '+anytim(v_START(i),/date_only,/ECS)+' '+anytim(v_START(i),/time_only,/ECS,/trunc)+' '
	ligne=ligne+anytim(v_END(i),/time_only,/ECS,/trunc)+' '+STRING(v_type(i),format='(A4)')+' '
	ligne=ligne+STRN(v_int(i))+' '+STRN(v_qual(i))+' '+STRING(v_sfrq(i),format='(I6)')+' '
	ligne=ligne+STRING(v_efrq(i),format='(I6)')+' '
	for j=0,4 do begin
		if v_feat(j,i) NE '' then ligne=ligne+STRTRIM(v_feat(j,i))+','
	endfor
	lastchar=STRMID(ligne,STRLEN(ligne)-1)				; extracts last character
	if lastchar EQ ',' then ligne=STRMID(ligne,0,STRLEN(ligne)-1)	; this simply removes last comma.
	print,ligne
	if not keyword_set(nocomments) then print,'Comments: '+v_com(i)
	if keyword_set(files) then print,'Files: '+v_fil(i)
endfor
print,''
print,'===================================='
print,''
END


