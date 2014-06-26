
;EXAMPLE: 
;	dir='/global/hercules/users/shilaire/HEDC/NEWDATA/'
;	files_regexp='*pte5*.info'
;	line_to_replace_regexp='.C03_ANA_PRODUCTTYPE:'
;	replacement_line='.C03_ANA_PRODUCTTYPE: PTE'
;
;	hedc_infofile_correction,dir,files_regexp,line_to_replace_regexp,replacement_line


PRO hedc_infofile_correction,dir,file_regexp_to_replace,line_regexp_to_replace,replacement_line

files=LOC_FILE(file_regexp_to_replace,PATH=dir,COUNT=COUNT,/ALL)
FOR j=0,N_ELEMENTS(files)-1 DO BEGIN

	OPENR,lun,/GET_LUN,files(j)
	
	a='blabla'
	lignes=''
	WHILE NOT EOF(lun) DO BEGIN
		READF,lun,a
		IF lignes(0) EQ '' THEN lignes=a ELSE lignes=[lignes,a]
	ENDWHILE			
	FREE_LUN,lun	
			
	tmp=grep(line_regexp_to_replace,lignes,index=index)
	PRINT,lignes(index)
	lignes(index)=replacement_line	
	
	OPENW,lun,files(j),/GET_LUN
	FOR i=0,N_ELEMENTS(lignes)-1 DO PRINTF,lun,lignes(i)
	FREE_LUN,lun

ENDFOR
END

