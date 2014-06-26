;+
; NAME:
;
;    pg_printnumber
;
; PURPOSE:
;
;    output the value of a float or double with the highest meaningful
;    precision
;
; CATEGORY:
;
;    numerical utilities
;
; CALLING SEQUENCE:
;
;    pg_printnumber,x
;
; INPUTS:
;
;    x: a numerical value or array
;
; OPTIONAL INPUTS:
;
; KEYWORD PARAMETERS:
; 
; OUTPUT:
; 
;    none, something is printed on the command line
;
; OPTIONAL OUTPUTS:
;
; COMMON BLOCKS:
;
; SIDE EFFECTS:
;
; RESTRICTIONS:
;
; PROCEDURE:
;
;    the machine precision value is taken from the EPS field from machar()
;
; AUTHOR:
;
;    Paolo Grigis, Institute of Astronomy, ETH Zurich
;    pgrigis@astro.phys.ethz.ch
;
; MODIFICATION HISTORY:
;
;    05-OCT-2005 written P.G.
;
;-


PRO pg_printnumber,x

s=size(x,/tname)

CASE s OF 

   'FLOAT' : m=machar()

   'DOUBLE': m=machar(/double)

   ELSE    : BEGIN 
                print,x
                RETURN
             END      
ENDCASE

eps=floor(alog10(m.eps))

fstring='(e'+strtrim(string(6-eps),2)+'.'+strtrim(string(-eps),2)+')'
print,x,format=fstring


END
