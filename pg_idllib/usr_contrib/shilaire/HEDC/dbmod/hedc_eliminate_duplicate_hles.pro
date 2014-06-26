

;WARNING: DON'T USE THIS ROUTINE IF YOU DON'T KNOW WHAT YER DOING!
; this routine must be run on hercules

FUNCTION hedc_eliminate_duplicate_hles, ERASE=ERASE, FORCE=FORCE
	;make a list of all HLEs
	cmd='java -cp "/global/hercules/users/shilaire/HEDC/util:/global/hercules/users/hedc/dm/classes/dm.jar:/global/hercules/users/hedc/dm/classes/sc_lib.jar" query S12_HLE_CODE ne zxcasdqwe S12_HLE_CODE'
	SPAWN,cmd,list
	
	;take those starting with HX
	HXlist=-1
	FOR i=0L,N_ELEMENTS(list)-1 DO BEGIN
		IF STRMID(list[i],0,2) EQ 'HX' THEN BEGIN
			IF datatype(HXlist[0]) EQ 'INT' THEN HXlist=list[i] ELSE HXlist=[HXlist,list[i]]
		ENDIF
	ENDFOR	

	;make list of duplicates 
	UniqHXlist=HXlist[UNIQ(HXlist, SORT(HXlist))]
	DuplicateList=-1
	FOR i=0L,N_ELEMENTS(UniqHXlist)-1 DO BEGIN
		ss=WHERE(HXlist eq UniqHXlist[i])
		IF N_ELEMENTS(ss) GE 2 THEN BEGIN
			IF datatype(DuplicateList[0]) EQ 'INT' THEN DuplicateList=UniqHXlist[i] ELSE DuplicateList=[DuplicateList,UniqHXlist[i]]
		ENDIF
	ENDFOR
	IF datatype(DuplicateList) EQ 'INT' THEN BEGIN
		PRINT,'No duplicate HLE in HEDC database.'
		RETURN,-1
	ENDIF
	
	;erase all duplicates except one with biggest LKY_HLE_ID (most recent)
	IF KEYWORD_SET(ERASE) THEN BEGIN
		FOR i=0L,N_ELEMENTS(DuplicateList)-1 DO BEGIN
			cmd='java -cp "/global/hercules/users/shilaire/HEDC/util:/global/hercules/users/hedc/dm/classes/dm.jar:/global/hercules/users/hedc/dm/classes/sc_lib.jar" query S12_HLE_CODE eq '+DuplicateList[i]+' LKY_HLE_ID'
			SPAWN,cmd,IDlist
		
			longIDlist=LONG(IDlist)
			SortedlongIDlist=longIDlist[SORT(longIDlist)]
			nbr_to_delete=N_ELEMENTS(SortedlongIDlist)-1
			
			PRINT,DuplicateList[i]+' has :'
			PRINT,SortedlongIDlist
			
			do_delete=0
			tmp='bla'
			IF KEYWORD_SET(FORCE) THEN do_delete=1 ELSE BEGIN
				PRINT,'Press "y" to delete: '
				PRINT,SortedlongIDlist[0:nbr_to_delete-1]
				READ,tmp
				IF tmp EQ 'y' THEN do_delete=1					
			ENDELSE				

			IF do_delete EQ 1 THEN BEGIN
				FOR j=0L,nbr_to_delete-1 DO BEGIN
					PRINT,'Deleting '+strn(SortedlongIDlist[j])+'...'
					cmd='java -cp "/global/hercules/users/shilaire/HEDC/util:/global/hercules/users/hedc/dm/classes/dm.jar:/global/hercules/users/hedc/dm/classes/sc_lib.jar" hedc_hsi_delete_HLE '+strn(SortedlongIDlist[j])
					SPAWN,cmd,IDlist	
				ENDFOR				
			ENDIF
		ENDFOR
	ENDIF
	
	RETURN,DuplicateList
END


