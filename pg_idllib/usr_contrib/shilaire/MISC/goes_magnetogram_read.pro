;+
; PURPOSE:
;	Will read GOES magnetograms from SEC NOAA
;
; OPTIONAL KEYWORD INPUT:
;	regexp: for a more zeroed-in search of files to take (otherwise, takes all files in directory...)
;
; EXAMPLE:
;	data=goes_magnetogram_read(regexp='200311')
;	utplot,data.time,ytit='[nT]',data.Htot
;	OPLOT,data.time,data.Hp,linestyle=1
;	OPLOT,data.time,data.He,linestyle=2
;	OPLOT,data.time,data.Hn,linestyle=3
;	utplot,data.time,ytit='[nT]',DERIV(data.time,data.Htot)
;-


FUNCTION goes_magnetogram_read, sat=sat, regexp=regexp
	IF NOT KEYWORD_SET(sat) THEN sat='G12'
	
;find all relevant files 
	sock_list,'http://www.sec.noaa.gov/ftpmenu/lists/geomag.html',page
	page=grep("_"+sat+"mag_1m.txt",page)	
	page=grep("a href=",page)	
	IF KEYWORD_SET(regexp) THEN page=grep(regexp,page)

	tmp=str_sep(page[0],'"')
	filelist=tmp[1]
	FOR i=1L,N_ELEMENTS(page)-1 DO BEGIN
		tmp=str_sep(page[i],'"')
		filelist=[filelist,tmp[1]]
	ENDFOR
PRINT,'..........list is made of '+strn(N_ELEMENTS(filelist))+' files.'

;now, read'em!
	ans='blabla'
	url_base='http://www.sec.noaa.gov'
	FOR i=0L,N_ELEMENTS(filelist)-1 DO BEGIN
		sock_list,url_base+filelist[i],page
		FOR j=0L,N_ELEMENTS(page)-1 DO BEGIN
			IF (STRMID(page[j],0,3) EQ '200') THEN BEGIN
				tmp=STRSPLIT(page[j],/EXTRACT)
				newitem={time: anytim(tmp[0]+'/'+tmp[1]+'/'+tmp[2]+' '+STRMID(tmp[3],0,2)+':'+STRMID(tmp[3],2,2)) , Hp: FLOAT(tmp[6]) ,He: FLOAT(tmp[7])  ,Hn:FLOAT(tmp[8]), Htot: FLOAT(tmp[9]) }	; in [nT]
				IF datatype(ans) EQ 'STR' THEN ans=newitem ELSE ans=[ans,newitem]
			ENDIF
		ENDFOR
		PRINT,' % completed: '+strn(100.*(i+1)/N_ELEMENTS(filelist),format='(f10.1)')
	ENDFOR

;now, remove bad values:
	good_ss=WHERE(ans.Htot GE 0)
	ans=ans[good_ss]
;now, sort the data by time
	ans=ans[SORT(ans.time)]
;now, return result!
	RETURN,ans
END

