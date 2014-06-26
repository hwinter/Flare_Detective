;+
;	PSH 2001/12/21
;
;	PURPOSE:
; 	This cool routine sends an email to somebody else, without using the usual mail tools.
;
;
;	RESTRICTIONS:
;		needs IDL >= 5.4 !!!
;
;	INPUTS:
;		recipient: 'username@hostname'
;		msg : don't put a dot (".") by itself at the beginning of a line: this is the end-of-message marker!
;		host	: if not specified, the 'hostname' part in 'recipient' is used.
;		sender : OPTIONAL KEYWORD (default is santa.claus@north.pole)
;		mailport: OPTIONAL KEYWORD (default is 25)
;		/loud	: displays sent & received messages: could be useful for debugging.
;
;
;	EXAMPLE:
;		send_email,'shilaire@helene.ethz.ch','Salut! Ca va?'
;		send_email,'shilaire@helene','Salut! Ca va?',/LOUD,sender='shilaire@carme'
;
;
;	PLANNED IMPROVEMENTS:
;		- array of recipients
;		- any email address (i.e. hostname not needed)
;		- subject ?  -- seems not implementable with SMTP...
;
;-




PRO send_email,recipient,msg,sender=sender,host=host,mailport=mailport,loud=loud

	ON_ERROR,2

	if not keyword_set(sender) then sender='santa@pole'
	if not keyword_set(mailport) then mailport=25	; 25 is the usual email port
	if not keyword_set(host) then begin
		tmp=rsi_strsplit(recipient,'@',/EXTRACT)
		host=tmp(1)
	endif

	socket_err=0
	SOCKET,lun1,host,mailport,/GET_LUN,err=socket_err
	IF socket_err eq 0 THEN BEGIN
		text='blabla'
		readf,lun1,text
			if keyword_set(loud) then print,'RECEIVED> '+text
		text='HELO '+host
		PRINTF,lun1,text
			if keyword_set(loud) then print,'SENT> '+text
		readf,lun1,text
			if keyword_set(loud) then print,'RECEIVED> '+text
		text='mail from: '+sender
		PRINTF,lun1,text
			if keyword_set(loud) then print,'SENT> '+text
		readf,lun1,text
			if keyword_set(loud) then print,'RECEIVED> '+text
		text='rcpt to: '+recipient
		PRINTF,lun1,text
			if keyword_set(loud) then print,'SENT> '+text
		readf,lun1,text
			if keyword_set(loud) then print,'RECEIVED> '+text
		PRINTF,lun1,'data'
			if keyword_set(loud) then print,'SENT> data'
		readf,lun1,text
			if keyword_set(loud) then print,'RECEIVED> '+text
		msg=msg+STRING(13B)+STRING(10B)+'.'+STRING(13B)+STRING(10B)
		PRINTF,lun1,msg
			if keyword_set(loud) then print,'SENT> '+msg
		readf,lun1,text
			if keyword_set(loud) then print,'RECEIVED> '+text
		PRINTF,lun1,'quit'
			if keyword_set(loud) then print,'SENT> quit'
		readf,lun1,text
			if keyword_set(loud) then print,'RECEIVED> '+text
		FREE_LUN,lun1
	ENDIF ELSE PRINT,'============= Socket not established ! ==============='
END



