;
;
;
; MODIFICATIONS:
;	PSH, 2001/11/02 : added FILE_DELETE before the printai call.
;	PSH, 2002/05/03 : replaced keyword 'movie_nbr' by 'moviename' + appropriate changes
;	PSH, 2002/05/05 : writes S12_ANA_CODE from S12_HLE_CODE, not using any other trick...
;




PRO hedc_write_info_file,dptype,ev_struct,info,filename,framenbr=framenbr,	$	; for DATA PRODUCTS ONLY (not necessary for .einfo files...)
		codeprefix=codeprefix, moviename=moviename

;NEEDED INFORMATION IN THE ev_struct:
;	.EVENT_CODE
;	.EVENT_TYPE
;	.SIMULATED
;	.MIN_ENERGY_FOUND
;	.MAX_ENERGY_FOUND
;	.EVENT_ID_NUMBER
;


; this routine writes only the pertinent information of the infostructure
; in the ascii file.

if not exist(framenbr) then framenbr=-9999

bla=systime(/utc)
bla=strmid(bla,8,2)+'-'+strmid(bla,4,3)+'-'+strmid(bla,22,2)+' '+strmid(bla,11,8)

infostruct={HEDC_PRODUCT_SCHEMA_1,						$
		s12_ana_code : 'HEC',							$
		c03_ana_productType: STRUPCASE(dptype),			$
		c04_ana_eventType:	ev_struct.EVENT_TYPE,		$
		c04_ana_imagingAlg : '-9999',					$
		s12_ana_movieCode: '-9999',						$
		i04_ana_movieFrame: framenbr,					$
		dat_ana_creationDate:anytim2oracle(bla),		$
		dat_ana_startDate : '-9999',					$
		i08_ana_startTime : -9999.,						$
		dat_ana_endDate : '-9999',						$
		i08_ana_endTime : -9999.,						$
		i08_ana_duration: -9999.,						$
		i05_ana_minEnergy : -9999.D,					$
		i05_ana_maxEnergy : -9999.D,					$
		f04_ana_ltcTimeRes : -9999.D,					$
		boo_ana_frontSegment : -9999,					$
		boo_ana_rearSegment : -9999,					$
		s09_ana_subCollUsed : '-9999',					$
		f04_ana_distanceSun : '-9999.',					$
		boo_ana_simulatedData : -9999,					$
		boo_ana_backgrSubtract: -9999,					$
		i04_ana_xDimension: -9999,						$
		i04_ana_yDimension: -9999,						$
		f04_ana_xPixelSize: -9999.,						$
		f04_ana_yPixelSize: -9999.,						$
		f04_ana_xPos: -9999.,							$
		f04_ana_yPos: -9999.,							$
		s20_ana_reserve1 : '2',							$
		s20_ana_reserve2 : '-9999',						$
		s20_ana_reserve3 : '-9999',						$
		s20_ana_reserve4 : '-9999',						$
		s20_ana_reserve5 : '-9999',						$
		s20_ana_reserve6 : '-9999',						$
		txt_ana_files : '',							$
		txt_ana_algParameter : '-9999',						$
		txt_ana_comments : ''	}
		

;fill in the infostruct...
infostruct.s12_ana_code=ev_struct.EVENT_CODE

IF datatype(info) eq 'STC' then begin	; we have an info &/or control structure... i.e. we have a Hessi IM, SP or LC

	infostruct.dat_ana_startDate = anytim2oracle(info.ABSOLUTE_TIME_RANGE[0])
	infostruct.i08_ana_startTime = anytim(info.ABSOLUTE_TIME_RANGE[0],/time_only)
	infostruct.dat_ana_endDate = anytim2oracle(info.ABSOLUTE_TIME_RANGE[1])
	infostruct.i08_ana_endTime = anytim(info.ABSOLUTE_TIME_RANGE[1],/time_only)
	infostruct.i08_ana_duration= anytim(info.ABSOLUTE_TIME_RANGE[1])-anytim(info.ABSOLUTE_TIME_RANGE[0])
	infostruct.i05_ana_minEnergy = info.ENERGY_BAND[0]
	infostruct.i05_ana_maxEnergy = info.ENERGY_BAND[1]

	IF dptype EQ 'sp' THEN BEGIN
		infostruct.i05_ana_minEnergy = -9999
		infostruct.i05_ana_maxEnergy = -9999
	ENDIF

	IF STRMID(dptype,0,2) EQ 'lc' THEN BEGIN
		infostruct.i05_ana_minEnergy = info.LTC_ENERGY_BAND[0]
		infostruct.i05_ana_maxEnergy = info.LTC_ENERGY_BAND[N_ELEMENTS(info.LTC_ENERGY_BAND)-1]
	ENDIF

	
	subcoll='000000000'	

	IF ((STRMID(dptype,0,1) EQ 'i') OR (STRMID(dptype,0,2) EQ 'pt') OR (dptype EQ 'scA') OR (dptype EQ 'tc1')) then BEGIN
			bla=hsi_coll_segment_list(info.det_index_mask,info.a2d_index_mask , info.front_segment,info.rear_segment,colls_used=coll)
			for i=0,8 do if coll(i) gt 0 then STRPUT,subcoll,'1',i
			infostruct.boo_ana_frontSegment=info.front_Segment
			infostruct.boo_ana_rearSegment=info.rear_Segment

			infostruct.c04_ana_imagingAlg=STRUPCASE(STRMID(info.IMAGE_ALGORITHM,0,4))
			infostruct.i04_ana_xDimension=info.IMAGE_DIM[0]
			infostruct.i04_ana_yDimension=info.IMAGE_DIM[1]
			infostruct.f04_ana_xPixelSize=info.PIXEL_SIZE[0]
			infostruct.f04_ana_yPixelSize=info.PIXEL_SIZE[1]	
			infostruct.f04_ana_distanceSun=sqrt(info.XYOFFSET[0]^2+info.XYOFFSET[1]^2)
			infostruct.f04_ana_xPos=info.xyoffset[0]
			infostruct.f04_ana_yPos=info.xyoffset[1]		      
	endif else begin
		for i=0,8 do BEGIN
			if info.seg_index_mask[i] gt 0 then infostruct.boo_ana_frontSegment=1B
			if info.seg_index_mask[i+9] gt 0 then infostruct.boo_ana_rearSegment=1B
			bla=info.seg_index_mask[i]+info.seg_index_mask[i+9]
			if bla gt 0 then STRPUT,subcoll,'1',i
		endfor
	endelse
	
	infostruct.s09_ana_subCollUsed=subcoll
	if infostruct.boo_ana_frontSegment ne 1B then infostruct.boo_ana_frontSegment=0B
	if infostruct.boo_ana_rearSegment ne 1B then infostruct.boo_ana_rearSegment=0B

	;which data file(s) ?
	bla=hsi_filedb_filename(info.ABSOLUTE_TIME_RANGE)
	for i=0,N_ELEMENTS(bla)-1 do infostruct.txt_ana_files=infostruct.txt_ana_files+getlog('HSI_DATA_ARCHIVE')+bla[i]+' '

	IF STRMID(dptype,0,2) EQ 'lc' then BEGIN
		infostruct.f04_ana_ltcTimeRes=info.LTC_TIME_RESOLUTION
	ENDIF
	;if framenbr gt -1  then infostruct.s12_ana_movieCode='M'+int2str(movie_nbr,2)+'_'+ev_struct.EVENT_TYPE+int2str(ev_struct.EVENT_ID_NUMBER,5)
	if framenbr gt -1  then infostruct.s12_ana_movieCode=moviename

	infostruct.txt_ana_algParameter=hedc_return_other_params(info)

	IF dptype EQ 'tc1' THEN infostruct.txt_ana_comments='True color image. RGB scaled to peak of map. R:6-12 keV; G:30-50 keV; B(if present):100-300 keV'
	
ENDIF ELSE BEGIN	; we have a Summary image...  S00 to S03+  ... or an image...
	; Fill it up...	   
	infostruct.dat_ana_startDate = anytim2oracle(info[0])
	infostruct.i08_ana_startTime = anytim(info[0],/time_only)
	infostruct.dat_ana_endDate = anytim2oracle(info[1])
	infostruct.i08_ana_endTime = anytim(info[1],/time_only)
	infostruct.i08_ana_duration= anytim(info[1])-anytim(info[0])

	;which data file(s) ?
	bla=hsi_filedb_filename(info)
	for i=0,N_ELEMENTS(bla)-1 do infostruct.txt_ana_files=infostruct.txt_ana_files+getlog('HSI_DATA_ARCHIVE')+bla(i)+' '
		
	if strmid(dptype,0,2) eq 'S0' then begin
		infostruct.f04_ana_ltcTimeRes = 4.
		infostruct.i05_ana_minEnergy = ev_struct.MIN_ENERGY_FOUND
		infostruct.i05_ana_maxEnergy = ev_struct.MAX_ENERGY_FOUND
	endif

	if dptype eq 'S00' then begin
		infostruct.boo_ana_frontSegment=1
		infostruct.boo_ana_rearSegment=1
		infostruct.s09_ana_subCollUsed='111111111'
		infostruct.boo_ana_backgrSubtract=0		
	endif
	if dptype eq 'hsg' then begin
		infostruct.boo_ana_frontSegment=1
		infostruct.boo_ana_rearSegment=1
		infostruct.s09_ana_subCollUsed='111111111'
		infostruct.boo_ana_backgrSubtract=0		
	endif
	ENDELSE
IF tag_exist(ev_struct,'SIMULATED') THEN infostruct.boo_ana_simulatedData=ev_struct.SIMULATED ELSE infostruct.boo_ana_simulatedData=0
infostruct.boo_ana_backgrSubtract=0
if infostruct.txt_ana_files eq '' then infostruct.txt_ana_files='-9999'
FILE_DELETE,filename,/QUIET
printai,infostruct,filename=filename
END

;*******************************************************************************
;*******************************************************************************
