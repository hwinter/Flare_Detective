;=====================================================================================================================================================================================
	PRINT,'DOING SINGLE FLARE!'
;hedc_solar_event,'2003/10/28 '+['11:00','11:40'],/STD,/ZBUFFER,newdatadir=GETENV('HEC_OUTPUT_DIR')+'/',/REMOVE_FROM_HEDC,flarelistid='3102825'
;hedc_solar_event,'2003/10/23 '+['08:45','09:40'],/STD,/ZBUFFER,newdatadir=GETENV('HEC_OUTPUT_DIR')+'/',/REMOVE_FROM_HEDC,flarelistid='0'

;-----------------------------------------------------------------------------------
gev=rapp_get_gev(['2003/10/19','2003/10/20'])
i=3
tmp=time2file(gev[i].PEAK_TIME)
eventcode='HYS'+STRMID(tmp,3,5)+STRMID(tmp,9,4)
hedc_solar_event,eventcode=eventcode,anytim(gev[i].START_TIME)+[0,3*gev[i].DURATION],/STD,/ZBUFFER,newdatadir=GETENV('HEC_OUTPUT_DIR')+'/',/REMOVE_FROM_HEDC,flarelistid='0'
;-----------------------------------------------------------------------------------
gev=rapp_get_gev(['2003/11/02','2003/11/03'])
i=3
tmp=time2file(gev[i].PEAK_TIME)
eventcode='HYS'+STRMID(tmp,3,5)+STRMID(tmp,9,4)
hedc_solar_event,eventcode=eventcode,anytim(gev[i].START_TIME)+[0,3*gev[i].DURATION],/STD,/ZBUFFER,newdatadir=GETENV('HEC_OUTPUT_DIR')+'/',/REMOVE_FROM_HEDC,flarelistid='0'
;-----------------------------------------------------------------------------------
gev=rapp_get_gev(['2003/11/03','2003/11/04'])
i=5
tmp=time2file(gev[i].PEAK_TIME)
eventcode='HYS'+STRMID(tmp,3,5)+STRMID(tmp,9,4)
hedc_solar_event,eventcode=eventcode,anytim(gev[i].START_TIME)+[0,3*gev[i].DURATION],/STD,/ZBUFFER,newdatadir=GETENV('HEC_OUTPUT_DIR')+'/',/REMOVE_FROM_HEDC,flarelistid='0'
;-----------------------------------------------------------------------------------
gev=rapp_get_gev(['2003/11/04','2003/11/05'])
i=6
tmp=time2file(gev[i].PEAK_TIME)
eventcode='HYS'+STRMID(tmp,3,5)+STRMID(tmp,9,4)
hedc_solar_event,eventcode=eventcode,anytim(gev[i].START_TIME)+[0,3*gev[i].DURATION],/STD,/ZBUFFER,newdatadir=GETENV('HEC_OUTPUT_DIR')+'/',/REMOVE_FROM_HEDC,flarelistid='0'
;-----------------------------------------------------------------------------------

PRINT,'IDL-OK'
;=====================================================================================================================================================================================
END


