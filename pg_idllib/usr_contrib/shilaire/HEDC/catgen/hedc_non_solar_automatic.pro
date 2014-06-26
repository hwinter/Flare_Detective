	;EXAMPLE:
	;hedc_non_solar_automatic, newdatadir='~/NEWHEDCDATA/'
	;hedc_non_solar_automatic, newdatadir='~/NEWHEDCDATA/',addintv=[-60,600]
;=====================================================================================================================================================================================
;=====================================================================================================================================================================================
;HEDC event generation from flare list...

PRO hedc_non_solar_automatic, newdatadir=newdatadir, addintv=addintv

IF NOT KEYWORD_SET(newdatadir) THEN newdatadir=GETENV('HEC_OUTPUT_DIR')+'/'
IF NOT KEYWORD_SET(addintv) THEN addintv=[-120,120.]

newitems=hedc_new_grb_sgr(MINTIME=10.,/NOBREAK)

IF datatype(newitems) EQ 'INT' THEN BEGIN
	IF newitems EQ -1 THEN PRINT,'.........no new items in the KONUS list'
	IF newitems EQ -2 THEN PRINT,'.........problem while extracting new items from the KONUS list'	
	GOTO,THEEND
ENDIF

PRINT,'!!!!!!!!!!!!  Will only do GRB and SGR !!!!!!!!!!!!!!!!!!!'

nbrtried=0
nbrdone=0
FOR j=0,N_ELEMENTS(newitems)-1 DO BEGIN

		es=0
		CATCH,es
		IF es NE 0 THEN BEGIN
			CATCH,/CANCEL
			PRINT,'...............................CAUGHT ERROR !......................'
			HELP, CALLS=caller_stack
			PRINT, 'Error index: ', es
			PRINT, 'Error message:', !ERR_STRING
			PRINT,'Error caller stack:',caller_stack
			HELP, /Last_Message, Output=theErrorMessage
			FOR k=0,N_Elements(theErrorMessage)-1 DO PRINT, theErrorMessage[k]
			es=0
			GOTO,LABEL01					
		ENDIF
				
		tmp=RSI_STRSPLIT(newitems[j],' ',/EXTRACT)
		obs_time=anytim(anytim(tmp[1]+' '+tmp[2])+addintv,/ECS)

		IF tmp[0] EQ 'GRB' THEN BEGIN
			PRINT,'...................Doing GRB: '+newitems[j]+' ................'
			nbrtried=nbrtried+1
			hedc_non_solar_event,obs_time,newdatadir=newdatadir,/STD,/ZBUFFER,eventtype='G',/REMOVE_FROM_HEDC,peaktim=anytim(tmp[1]+' '+tmp[2])
			nbrdone=nbrdone+1						
		ENDIF
		
		IF tmp[0] EQ 'SGR' THEN BEGIN
			PRINT,'...................Doing SGR: '+newitems[j]+' ................'
			nbrtried=nbrtried+1
			hedc_non_solar_event,obs_time,newdatadir=newdatadir,/STD,/ZBUFFER,eventtype='R',/REMOVE_FROM_HEDC,peaktim=anytim(tmp[1]+' '+tmp[2])
			nbrdone=nbrdone+1						
		ENDIF
		
		LABEL01:
		HEAP_GC
ENDFOR
PRINT,'............There were '+strn(N_ELEMENTS(newitems))+' new and modified items in the KONUS list.'
PRINT,'............Only '+strn(nbrtried)+' were attempted (i.e. GRBs and SGRs).'
PRINT,'............'+strn(nbrdone)+' were completed.'

THEEND:
END
;=====================================================================================================================================================================================
