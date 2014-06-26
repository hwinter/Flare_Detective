;+
;
;Program dn: do nothing (well, not really nothing...)
;useful to keep connection open to hercules against timeout!!!
;
;-

PRO dn,quiet=quiet

i=0L

REPEAT BEGIN

   IF (i MOD 10 EQ 0) AND NOT keyword_set(quiet) THEN BEGIN 
      print,i,'  seconds have elapsed. Press any key to stop'
   ENDIF

   i=i+1
   wait,1
   A = GET_KBRD(0)

ENDREP UNTIL A NE ''


END
