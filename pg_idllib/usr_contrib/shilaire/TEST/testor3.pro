PRO testor3
openr,1,'HESSI/hedc_log/OF_last_list.log'
ligne='abcdefg'
while eof(1) eq 0 do BEGIN
		readf,1,ligne		
		bla=STRSPLIT(ligne,/EXTRACT)	; IDL's STRSPLIT, not SLF's !!!
		time_interval=[anytim(bla(0)),anytim(bla(1))]
		print,ligne,anytim(time_interval,/yoh)
		     ENDWHILE
close,1
END
