
; This routine extracts all GRBs and SGRs from KONUS list.
; The current list is stored.
;
; PSH 2003/09/08: added CATCH statement...
;


FUNCTION hedc_new_grb_sgr, listdir=listdir, url=url, NOREPLACE=NOREPLACE, MINTIME=MINTIME, NOBREAK=NOBREAK
		es=0
		CATCH,es
		IF es NE 0 THEN BEGIN
			CATCH,/CANCEL
			PRINT,'...............................CAUGHT ERROR while trying to extract new items from KONUS list........returning -2..............'
			HELP, CALLS=caller_stack
			PRINT, 'Error index: ', es
			PRINT, 'Error message:', !ERR_STRING
			PRINT,'Error caller stack:',caller_stack
			HELP, /Last_Message, Output=theErrorMessage
			FOR k=0,N_Elements(theErrorMessage)-1 DO PRINT, theErrorMessage[k]
			es=0
			RETURN,-2					
		ENDIF

	;MINTIME is the minimal amount of time (in days) before an appropriate item is done (i.e. wait 'till HESSI data gets in !).
IF NOT KEYWORD_SET(MINTIME) THEN MINTIME=0.
IF NOT KEYWORD_SET(listdir) THEN listdir='/global/hercules/users/shilaire/LOGS/KONUS'
IF NOT KEYWORD_SET(url) THEN url='http://gcn.gsfc.nasa.gov/gcn/konus_grbs.html'

;1) Extract the old and new list-----------------------------------------------------------------------
sock_list,url,newhtmllist,/cgi

IF N_ELEMENTS(newhtmllist) LT 100 THEN BEGIN
	IF KEYWORD_SET(NOBREAK) THEN BEGIN
		PRINT,'.....!!! PROBLEM WITH READING THE REMOTE FILE -- returning -2 ....'
		RETURN,-2 
	ENDIF ELSE MESSAGE,'.....!!! PROBLEM WITH READING THE REMOTE FILE -- CRASHING NOW...'
ENDIF

oldlist=-1
newlist=-1
IF file_exist(listdir+'/lastlist.txt') THEN BEGIN
	oldlist=rd_text(listdir+'/lastlist.txt')	
ENDIF ELSE BEGIN
	PRINT,'............ old list not there... replacing, and doing nothing....'
	GOTO,THEEND
ENDELSE
	

;2) Compare new list with old one (lastlist.html), and extract new items. (type/time)-----------------------------------------------------------------------
	;a) transform newhtmllist to newlist
startregexp='XXXXXX'
endregexp='</tr></table>'
bla=grep(startregexp,newhtmllist,index=newliststartindex)
bla=grep(endregexp,newhtmllist,index=newlistendindex)
tmp=''
FOR i=newliststartindex+1,newlistendindex DO tmp=tmp+newhtmllist[i]
tmp=str_sep(tmp,'<tr')

FOR i=1,N_ELEMENTS(tmp)-1 DO BEGIN
	bla=str_sep(tmp[i],'<td>',/REMOVE_ALL)
	thedatetime=STRMID(bla[1],0,4)+'/'+STRMID(bla[1],4,2)+'/'+STRMID(bla[1],6,2)+' '+STRMID(bla[3],0,12)
	bla=str_sep(bla[5],'</td>')
	thetype=bla[0]
	IF strn(thetype) EQ '' THEN thetype='???'
	
	IF datatype(newlist) EQ 'INT' THEN newlist=thetype+' '+thedatetime ELSE newlist=[newlist,thetype+' '+thedatetime]
ENDFOR

	;b) for each item of newlist, check whether it already exists in oldlist. If not, we have a new item !
newitems=-1
FOR i =0,N_ELEMENTS(newlist)-1 DO BEGIN
	IF (grep(newlist[i],oldlist))[0] EQ '' THEN BEGIN
		IF datatype(newitems) EQ 'INT' THEN newitems=newlist[i] ELSE newitems=[newitems,newlist[i]]
	ENDIF
ENDFOR

;3) All event sooner than MINTIME (in days) are automatically labeled '???' (also insures that HESSI data has time to arrive!).----------------------
; do those changes BOTH in newlist AND newitems
today=systim2anytim()
FOR i=0,N_ELEMENTS(newlist)-1 DO BEGIN
	tmp=rsi_strsplit(newlist[i],' ',/EXTRACT)
	thetime=anytim(tmp[1]+' '+tmp[2])
	IF (thetime GT (today-MINTIME*86400.)) THEN newlist[i]='??? '+anytim(thetime,/ECS)
ENDFOR

IF datatype(newitems) NE 'INT' THEN BEGIN
	FOR i=0,N_ELEMENTS(newitems)-1 DO BEGIN
		tmp=rsi_strsplit(newitems[i],' ',/EXTRACT)
		thetime=anytim(tmp[1]+' '+tmp[2])
		IF (thetime GT (today-MINTIME*86400.)) THEN newitems[i]='??? '+anytim(thetime,/ECS)
	ENDFOR
ENDIF



THEEND:

;4) Replace old list with new one-----------------------------------------------------------------------------------------------------------------------
IF NOT KEYWORD_SET(NOREPLACE) THEN BEGIN
	OPENW,lun,/GET_LUN,listdir+'/lastlist.txt'
	FOR i=0,N_ELEMENTS(newlist)-1 DO PRINTF,lun,newlist[i]
	FREE_LUN,lun
ENDIF

;5) Output the difference between the two lists-----------------------------------------------------------------------------------------------------

IF datatype(newitems) EQ 'INT' THEN RETURN,-1 ELSE RETURN,newitems
END

