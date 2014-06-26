;============================================================================
;+
; NAME:  rapp_dbfind.pro
;
; PURPOSE:  
;	Emulates dbfind.pro
;
; CALLING SEQUENCE: 
;	list = rapp_dbfind(spar,fspar=fspar, [ listin, /FULLSTRING, ERRMSG=, Count = ])
; INPUTS:
;
; KEYWORD INPUT:
;	exactly as dbfind.pro, except for the additional :
;	* features keyword, to be used for queries involving the 'FEATURES' item (i.e. queries
;		are ORed between all FEATURES values)
;	* time_intv
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
;	list = rapp_dbfind(fspar='P',time_intv='2000/08/25 '+['13:00:00','15:00:00'])
;	list = rapp_dbfind('QUALITY>2',fspar='P',time_intv='2000/08/25 '+['13:00:00','15:00:00'])
;	
; HISTORY:
;       Written Pascal Saint-Hilaire, 2002/01/06.
;			shilaire@astro.phys.ethz.ch OR psainth@hotmail.com
; MODIFICATIONS:
;
;-
;===========================================================================================

function rapp_dbfind, spar, listin,SILENT=silent,fullstring = Fullstring,      $
       errmsg=errmsg,  Count = count, feature=feature, time_intv=time_intv

IF not exist(spar) then spar=''
IF keyword_set(time_intv) then begin
	IF spar EQ '' then spar='START_ANYTIM<'+strn(anytim(time_intv(1),/trunc),format='(I15)')+','+'END_ANYTIM>'+strn(anytim(time_intv(0),/trunc),format='(I15)') $
	ELSE spar=spar+',START_ANYTIM<'+strn(anytim(time_intv(1),/trunc),format='(I15)')+','+'END_ANYTIM>'+strn(anytim(time_intv(0),/trunc),format='(I15)')
ENDIF

IF exist(feature) then begin
	if spar eq '' then comma='' else comma=','
	spar1=spar+comma+'FEATURES(0)='+feature
	if exist(listin) then list1=dbfind(spar1,listin,SILENT=silent,fullstring = Fullstring,errmsg=errmsg, Count = count) $
	else list1=dbfind(spar1,/silent,fullstring = Fullstring,errmsg=errmsg, Count = count)
	
	spar1=spar+comma+'FEATURES(1)='+feature
	if exist(listin) then list2=dbfind(spar1,listin,SILENT=silent,fullstring = Fullstring,errmsg=errmsg, Count = count) $
	else list2=dbfind(spar1,/silent,fullstring = Fullstring,errmsg=errmsg, Count = count)
	
	list3=db_or(list1,list2)
	
	spar1=spar+comma+'FEATURES(2)='+feature
	if exist(listin) then list1=dbfind(spar1,listin,SILENT=silent,fullstring = Fullstring,errmsg=errmsg, Count = count) $
	else list1=dbfind(spar1,/silent,fullstring = Fullstring,errmsg=errmsg, Count = count)
	
	spar1=spar+comma+'FEATURES(3)='+feature
	if exist(listin) then list2=dbfind(spar1,listin,SILENT=silent,fullstring = Fullstring,errmsg=errmsg, Count = count) $
	else list2=dbfind(spar1,/silent,fullstring = Fullstring,errmsg=errmsg, Count = count)
	
	list4=db_or(list1,list2)
	
	spar1=spar+comma+'FEATURES(4)='+feature
	if exist(listin) then list2=dbfind(spar1,listin,SILENT=silent,fullstring = Fullstring,errmsg=errmsg, Count = count) $
	else list2=dbfind(spar1,/silent,fullstring = Fullstring,errmsg=errmsg, Count = count)
	
	list=db_or(list2,list3)
	list=db_or(list,list4)
	
ENDIF ELSE BEGIN
	if exist(listin) then list=dbfind(spar,listin,SILENT=silent,fullstring = Fullstring,errmsg=errmsg, Count = count) $
	else list=dbfind(spar,/silent,fullstring = Fullstring,errmsg=errmsg, Count = count)
ENDELSE

if ((list(0) EQ 0) AND (n_elements(list) GT 0)) then list=list(1:*)
return,list
END

