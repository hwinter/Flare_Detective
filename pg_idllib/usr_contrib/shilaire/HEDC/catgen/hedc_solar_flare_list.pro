;
;Just enter time ranges of NOAA, where HESSI was 10 min out of S/C night, and not in SAA
;
;
;====================================================================================================================================================
err_status=0
FOR i=0L,27 DO BEGIN
	CATCH, err_status
		IF err_status NE 0 THEN BEGIN
			err_status=0
		GOTO,NEXTPLEASE
		ENDIF

	CASE i OF
		0: hedc_solar_event,'2002/02/20 '+['09:45:00','10:10:00'],/ALL,/ZBUFFER,xyoffset=[930,200]
		1: hedc_solar_event,'2002/02/20 '+['11:00:00','11:15:00'],/ALL,/ZBUFFER
		2: hedc_solar_event,'2002/02/20 '+['16:15:00','16:35:00'],/ALL,/ZBUFFER ,xyoffset=[-175,175]
		3: hedc_solar_event,'2002/02/20 '+['21:00:00','21:15:00'],/ALL,/ZBUFFER ,xyoffset=[350,-150]	;spin axis!	[350,-150]
		4: hedc_solar_event,'2002/02/25 '+['02:40:00','03:10:00'],/ALL,/ZBUFFER 
		5: hedc_solar_event,'2002/02/27 '+['15:45:00','16:05:00'],/ALL,/ZBUFFER ,xyoffset=[850,-300]
		6: hedc_solar_event,'2002/03/03 '+['01:55:00','02:20:00'],/ALL,/ZBUFFER ,xyoffset=[100,500]	;spin axis!	[-400,350]
		7: hedc_solar_event,'2002/03/05 '+['05:25:00','05:45:00'],/ALL,/ZBUFFER ,xyoffset=[750,300]
		8: PRINT,'NOT DOING THIS ONE.'	;time_intv='2002/03/13 '+['21:55:00','22:35:00'],/ALL,/ZBUFFER 	;pbs!
		9: PRINT,'NOT DOING THIS ONE.'	;time_intv='2002/03/03 '+['23:10:00','23:59:59'],/ALL,/ZBUFFER 	;pbs!
		10:hedc_solar_event,'2002/02/21 '+['18:02:00','18:40:00'],/ALL,/ZBUFFER
		11:hedc_solar_event,'2002/02/23 '+['22:40:00','23:05:00'],/ALL,/ZBUFFER 
		12:PRINT,'NOT DOING THIS ONE.'	;time_intv='2002/02/24 '+['23:05:00','23:30:00'],/ALL,/ZBUFFER 	;pbs!
		13:hedc_solar_event,'2002/02/25 '+['21:20:00','21:40:00'],/ALL,/ZBUFFER 
		14:hedc_solar_event,'2002/02/26 '+['10:20:00','10:40:00'],/ALL,/ZBUFFER 
		15:hedc_solar_event,'2002/02/27 '+['00:35:00','01:00:00'],/ALL,/ZBUFFER 
		16:hedc_solar_event,['2002/02/27 23:45:00','2002/02/28 00:08:00'],/ALL,/ZBUFFER 
		17:hedc_solar_event,'2002/02/28 '+['09:15:00','09:40:00'],/ALL,/ZBUFFER  ,xyoffset=[-50,-225]
		18:hedc_solar_event,'2002/03/05 '+['03:30:00','03:55:00'],/ALL,/ZBUFFER  ;,xyoffset=[900,350]	;spin axis!	[100,900]
		19:hedc_solar_event,'2002/03/06 '+['08:25:00','08:50:00'],/ALL,/ZBUFFER  ,xyoffset=[925,-325]	;spin axis!	[850,450]
		20:hedc_solar_event,'2002/03/07 '+['16:15:00','16:35:00'],/ALL,/ZBUFFER ,xyoffset=[925,270]	
		21:hedc_solar_event,'2002/03/17 '+['10:05:00','10:21:00'] ,/ALL,/ZBUFFER,xyoffset=[-350,-250]	
		22:hedc_solar_event,'2002/03/17 '+['19:20:00','19:42:00'] ,/ALL,/ZBUFFER
		23:hedc_solar_event,'2002/03/29 '+['20:26:00','20:50:00'] ,/ALL,/ZBUFFERxyoffset=[-600,270]	
		24:hedc_solar_event,'2002/03/18 '+['19:05:00','19:25:00'],/ALL,/ZBUFFER,xyoffset=[-50,-250] 
		25:hedc_solar_event,'2002/04/10 '+['12:25:00','13:00:00'],/ALL,/ZBUFFER,backgndtime='2002/04/10 '+['12:10:00','12:11:00']
		26:hedc_solar_event,'2002/04/21 '+['00:37:00','01:40:00'],/ALL,/ZBUFFER,xyoffset=[-800,550], addimgtimes='2002/04/21 '+['01:06:30','01:12:00','01:15:00','01:22:30']
		27:hedc_solar_event,'2002/04/21 '+['02:06:00','02:23:00'],/ALL,/ZBUFFER,backgndtime='2002/04/21 '+['00:37:00','00:38:00'],xyoffset=[-800,550]

		ELSE: PRINT,'None.........'
	ENDCASE
	
NEXTPLEASE:
CATCH,/CANCEL
ENDFOR
END
