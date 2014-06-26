;
; alias for print
;
; written 05-SEP-2005
; fixed   22-OCT-2010 based on suggestions form the iDL newsgroup
; pgrigis@gmail.com
;

PRO pritn,a1,a2,a3,a4,a5,a6,a7,_extra=_extra

CASE n_params() OF
   1: print,a1,_extra=_extra
   2: print,a1,a2,_extra=_extra
   3: print,a1,a2,a3,_extra=_extra
   4: print,a1,a2,a3,a4,_extra=_extra
   5: print,a1,a2,a3,a4,a5,_extra=_extra
   ELSE: print,'Incorrect number of arguments'
ENDCASE




END



