;
; This function copies files with blanks in their filename
; to files with underscores instead
;

PRO pg_replace_blanks_in_filenames,directory=directory

IF file_exist(directory) EQ 0 THEN RETURN


files=file_search(directory,'*')

newfiles=files

FOR i=0,n_elements(files)-1 DO BEGIN 

   strsplitres=strsplit(files[i],' ',/extract)

   IF n_elements(strsplitres) GT 0 THEN BEGIN 
      
      newfiles[i]=strjoin(strsplitres,'_')

      pritn,'Copying '+files[i]+' to '+newfiles[i]
      file_copy,files[i],newfiles[i]
      


   ENDIF 


ENDFOR



;print,newfiles;


END


