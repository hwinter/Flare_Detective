;=====================================================================================================================================================================================
; this file is called via cronjob, and updates the HEDC with the latest flares...
;=====================================================================================================================================================================================
;read special file for last day done, then update when it is done...
default_start_date='2004/07/01'
fil='/global/hercules/data1/hedc/data/HECgeneration/reprocessing_day_2.txt'
IF NOT file_exist(fil) THEN BEGIN
	PRINT,'........'+fil+' does not exist! Creating one starting at '+default_start_date
	wrt_ascii,default_start_date,fil
ENDIF

thedate=rd_ascii(fil)
time_intv=anytim(thedate,/date)+[0.,86399.]
IF time_intv[0] GE systim2anytim() THEN PRINT,'time_intv bigger than current date!!!!' ELSE BEGIN
	PRINT,'NOW PROCESSING:'
	PRINT,anytim(time_intv,/ECS)
	;hedc_non_solar_automatic
	hedc_solar_automatic2,time_intv	,/GOESmin

	wrt_ascii,anytim(anytim(thedate)+86400,/date,/ECS),fil
	PRINT,'IDL-OK'
ENDELSE
END
;=====================================================================================================================================================================================
