;==============================================================================================================
; PURPOSE:
;	given a time interval and a frequency interval, returns apropriate rag array
;		(in linear, SFU scale)
;
; INPUT KEYWORDS:
;	NOELIM : if set, ELIMWRONGCHANNELS is not run.
;
; OUTPUT KEYWORDS:
;	xaxis
;	yaxis
;
; EXAMPLE:
;	rag_get_array([tim1,tim2],[frq1,frq2])
;
; HISTORY:
;	Written in 15 minutes, debugged in 2 min. (scrounged from other programs) 'cause I needed it!	PSH 2001/11/15
;	Now made OBSELETE by rapp_get_array.pro
;
;==============================================================================================================


PRO Merge, im1, im2, xAxis1, xAxis2, yAxis1, yAxis2, $
	im, xAxis, yAxis, ADJUST = adjust

  nx1 = N_Elements( xAxis1 ) & nx2 = N_Elements( xAxis2 )
  ny1 = N_Elements( yAxis1 ) & ny2 = N_Elements( yAxis2 )

  IF nx1 GT nx2 THEN BEGIN
    xAxis = xAxis1
    nxBoth = nx1
    IF Keyword_Set( ADJUST ) THEN $
      im2 = ConGrid1D( im2, nxBoth, ny2 ) 
  ENDIF ELSE  BEGIN
    xAxis = xAxis2
    nxBoth = nx2
    IF Keyword_Set( ADJUST)  THEN $
      im1 = ConGrid1D( im1, nxBoth, ny1 )
  ENDELSE

  yAxis = [ yAxis1, yAxis2 ]
  nyBoth = ny1 + ny2

  im = FltArr( nxBoth, nyBoth )
  im(0, 0) = im1
  im(0, ny1) = im2

END ; Merge images  



PRO qv_elimwrong, image, xaxis, yaxis 
 print, "Eliminating wrong channels"
 image_old = image
 xaxis_old = xaxis
 yaxis_old = yaxis
 ElimWrongChannels, image, xaxis, yaxis
 if n_elements(image(0,*)) le 1 then begin 
    print, "Restoring original image"
    image = image_old
    xaxis = xaxis_old
    yaxis = yaxis_old
 endif
END

;******************************************************************************
FUNCTION return_time_interval_of_ragfile,ragfile
; this function is valid until the year 7000... :)
; ragfile can have a path
; RESTRICTIONS : I assume duration is 15 minutes... not always true !!!!!!!!

lastslashpos=STRPOS(ragfile,'/',/REVERSE_SEARCH)
basicfilename=STRMID(ragfile,lastslashpos+1)

;if basicfilename starts by 7,8, or 9 it means I have to add 19 in front for the time...
timename=basicfilename
firstchar=STRMID(timename,0,1)
if ((firstchar eq '7') OR (firstchar eq '8') OR (firstchar eq '9')) then timename='19'+timename

time_part=STRMID(timename,8)
time_part='_'+time_part
STRPUT,timename,time_part,8
timeintv=file2time(timename,out_style='ECS')
timeintv=anytim(timeintv)
timeintv=[timeintv,timeintv+15.*60.]	; OK, here I assume the duration is 15 minutes.
RETURN,anytim(timeintv,/ECS)
END
;******************************************************************************



;******************************************************************************
FUNCTION get_rag_files,time_intv,valid_file_identifiers=valid_file_identifiers
; this function should work for any rag fits after 1978 (excl.)
if not exist(valid_file_identifiers) then valid_file_identifiers=['*l1.fit.gz','*l2.fit.gz','*i.fit.gz','*p.fit.gz']	;this thing should always have at least one element !

time_interval=anytim(time_intv)

;some constants
dir_time_interval=3600.*24.	;	the lowest possible directory levels are 1 day long
IF anytim(time_interval(0),/date) GT anytim('2001/01/01') THEN rag_root='/global/helene/local/rag/observations/' ELSE rag_root='/global/hercules/data1/rag/observations/'
;initialize output
ragfile=-1

;get the list of absolute directory paths to be checked (chronological)
dirlist=-1
currentdatetime=time_interval(0)
enddatetime=time_interval(1)
while (currentdatetime le enddatetime) do begin
	bla=anytim(currentdatetime,/EX)
	bla=rag_root+int2str(bla(6),4)+'/'+int2str(bla(5),2)+'/'+int2str(bla(4),2)+'/'
	if datatype(dirlist) eq 'INT' then dirlist=bla else dirlist=[dirlist,bla]
	currentdatetime=currentdatetime+dir_time_interval
endwhile

if datatype(dirlist) eq 'INT' then return,-1

;now, for EACH directory in dirlist, get filelist, and check if within time_interval
filelist=-1
for i=0,n_elements(dirlist)-1 do begin
	bla=findfile(dirlist(i)+'*')

	; now, for each filename in bla, check if ends with correct possible identifiers,
	; and append to filelist

	for j=0,n_elements(valid_file_identifiers)-1 do begin
		temp=WHERE(STRMATCH(bla,valid_file_identifiers(j),/FOLD_CASE) eq 1)
		if temp(0) ne -1 then begin
			temp=bla(temp)
			if datatype(filelist) eq 'INT' then filelist=temp else filelist=[filelist,temp]
		endif
	endfor
endfor

; now, check which ones are in the correct time interval, and return them...
if datatype(filelist) eq 'INT' then RETURN,-1

for i=0,n_elements(filelist)-1 do begin
	if has_overlap(time_interval,anytim(return_time_interval_of_ragfile(filelist(i)))) then begin
		if datatype(ragfile) eq 'INT' then ragfile=filelist(i) ELSE ragfile=[ragfile,filelist(i)]
	endif
endfor

return,ragfile
END
;******************************************************************************





FUNCTION rag_get_array,time_intv, freq_intv, xaxis=xaxis, yaxis=yaxis, NOELIM=NOELIM
	
	ragfiles=get_rag_files(time_intv,valid_file_identifiers=['*l1.fit*','*l2.fit*','*i.fit*'])
	nb_files=N_ELEMENTS(ragfiles)
	ragfitsread,ragfiles(0),image,xaxis,yaxis,/SILENT,bunit=bunit
			CASE bunit OF
				'solar flux units (sfu)': PRINT,bunit
				'45*ln10(solar flux units (sfu) + 10)': BEGIN
					image=10^(image/45.) - 10
					PRINT,bunit
				END
				'45*alog(solar flux units (sfu)+10)': BEGIN
					image=exp((image/45.)) - 10
					PRINT,bunit
				END						
				ELSE: BEGIN
					PRINT,'......................The encoding format: "'+bunit+'" is NOT recognized!!!'
					EXIT,/NO_CONFIRM,STATUS=2
				END
			ENDCASE										
			IF nb_files GT 1 THEN begin
				FOR j=1,nb_files-1 DO begin
					ragfitsread,ragfiles(j),img,xax,yax,/SILENT,bunit=bunit
					CASE bunit OF
						'solar flux units (sfu)': PRINT,bunit
						'45*ln10(solar flux units (sfu) + 10)': BEGIN
							img=10^(img/45.) - 10
							PRINT,bunit
						END
						'45*alog(solar flux units (sfu)+10)': BEGIN
							img=exp((img/45.)) - 10
							PRINT,bunit
						END						
						ELSE: BEGIN
							PRINT,'......................The encoding format: "'+bunit+'" is NOT recognized!!!'
							EXIT,/NO_CONFIRM,STATUS=2
						END
					ENDCASE										
					Merge, Transpose(image), Transpose(img), $
						yaxis, yax, xaxis, xax, $
						newimage, newyaxis, newxaxis,/ADJUST 
					image = Transpose(newimage)
					xaxis=newxaxis
					yaxis=newyaxis
				ENDFOR
			ENDIF
	
	;at this point, image is always an image in LINEAR SFU SCALE !!!
	IF NOT KEYWORD_SET(NOELIM) THEN qv_elimwrong, image, xaxis, yaxis
	
	
	
	ss_start=WHERE(xaxis GT (anytim(time_intv(0),/time_only)))	
	ss_start=ss_start(0)
	ss_end=WHERE(xaxis GT (anytim(time_intv(1),/time_only)))
	ss_end=ss_end(0)
	image=image(ss_start:ss_end,*)
	xaxis=xaxis(ss_start:ss_end)		

	ss_start=WHERE(yaxis LT freq_intv(1))
	ss_start=ss_start(0)
	ss_end=WHERE(yaxis LT freq_intv(0))
	ss_end=ss_end(0)
	image=image(*,ss_start:ss_end)
	yaxis=yaxis(ss_start:ss_end)

RETURN,image
END
