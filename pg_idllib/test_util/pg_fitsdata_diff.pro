;+
;
; NAME:
;       pg_fitsdata_diff
;
; PURPOSE:
;       tool for checking differences between FITS files (uses MRDFITS)
;
; CATEGORY:
;       file integrity check
;
;
; CALLING SEQUENCE:
;       pg_fitsdata_diff,file1,file2
;       
; INPUTS:
;       file1,2: teo filename
;
; HISTORY:
;       21-NOV-2005 written pgrigis@astro.phys.ethz.ch
;
;-

PRO pg_fitsdata_diff,file1,file2

IF NOT exist(file1)  THEN BEGIN 
   print,'Could not find input file 1'
   RETURN
ENDIF
IF NOT exist(file2)  THEN BEGIN 
   print,'Could not find input file 2'
   RETURN
ENDIF

data1=mrdfits(file1,0,header1,status=status1,/silent)
IF status1 LT 0 THEN BEGIN 
   print,'ERROR READING FILE 1'
   RETURN
ENDIF

data2=mrdfits(file1,0,header2,status=status2,/silent)
IF status2 LT 0 THEN BEGIN 
   print,'ERROR READING FILE 1'
   RETURN
ENDIF

nextension=0

WHILE (status1+status2) GE 0 DO BEGIN
   print,'NOW TESTING EXTENSION '+strtrim(string(nextension),2)
   ind=where(header1 NE header2,count)
   IF count GT 0 THEN BEGIN 
      print,'   HEADERS DIFFER!'
      RETURN
   ENDIF

   IF (size(data1,/tname) EQ 'STRUCT') AND (size(data1,/tname) EQ 'STRUCT') THEN BEGIN
      t1=tag_names(data1)
      t2=tag_names(data2)
      IF N_ELEMENTS(t1) NE N_ELEMENTS(t2) THEN BEGIN
         print,'   DIFFERENT NUMBER OF DATA FIELDS '
      ENDIF
      FOR i=0,n_elements(t1)-1 DO BEGIN 
         print,'   now checking '+t1[i]
         ind=where(data1[*].(i) NE data2[*].(i),count)
         IF count NE 0 THEN BEGIN
            print,'   DATA FIELD "'+t1[i]+'" DIFFER IN '+strtrim(string(count),2)+' ELEMENTS'
         ENDIF
      ENDFOR
            
   ENDIF

   nextension=nextension+1

   data1=mrdfits(file1,nextension,header1,status=status1,/silent)
   data2=mrdfits(file2,nextension,header2,status=status2,/silent)

ENDWHILE 

IF status1 EQ -1 THEN BEGIN 
   print,'ERROR READING FILE 1'
   RETURN
ENDIF

IF status2 EQ -1 THEN BEGIN 
   print,'ERROR READING FILE 1'
   RETURN
ENDIF

END

