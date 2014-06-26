
; will look at every .info and .einfo files, and put the right code !!!





dir='/global/hercules/users/shilaire/HEDC/NEWDATA/'
files=LOC_FILE('*pte5*.info',PATH=dir,COUNT=COUNT,/ALL)

j=0
FOR j=0,N_ELEMENTS(files)-1 DO BEGIN

	OPENR,lun,/GET_LUN,files(j)
	
	a='blabla'
	lignes=''
	WHILE NOT EOF(lun) DO BEGIN
		READF,lun,a
		IF lignes(0) EQ '' THEN lignes=a ELSE lignes=[lignes,a]
	ENDWHILE			
	FREE_LUN,lun	
			
	tmp=grep('.C03_ANA_PRODUCTTYPE:',lignes,index=index)
	PRINT,lignes(index)
	lignes(index)='.C03_ANA_PRODUCTTYPE: PTE'	
	
	OPENW,lun,files(j),/GET_LUN
	FOR i=0,N_ELEMENTS(lignes)-1 DO PRINTF,lun,lignes(i)
	FREE_LUN,lun

ENDFOR
END

