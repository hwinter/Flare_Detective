;+
; NAME:
;
; pg_sortintervals
;
; PURPOSE:
;
; hard to explain... let's try: let the inputs be two set of number,
; the "in" numbers and the "out" numbers. Ideally, they would describe
; a set of interval between each pair of "in" and "out" numbers.
; That means that the intervals would be described by in[0]:out[0],
; in[1]:out[1], etc. etc. Now the purpose of this routine is to fix
; input arrays in and out that have some mismatch in them, for instance
; in[2] lies between in[1] and out[1]. In such a case, in[2] will be deleted.
; Or out[1] lies between in[1] and out[2]. In this case, out[1] will be deleted.
;
; CATEGORY:
;
;
;
; CALLING SEQUENCE:
;
;
;
; INPUTS:
;
;
;
; OPTIONAL INPUTS:
;
;
;
; KEYWORD PARAMETERS:
;
;
;
; OUTPUTS:
;
;
;
; OPTIONAL OUTPUTS:
;
;
;
; COMMON BLOCKS:
;
;
;
; SIDE EFFECTS:
;
;
;
; RESTRICTIONS:
;
;
;
; PROCEDURE:
;
;
;
; EXAMPLE:
;
; .comp pg_sortintervals
;
; AUTHOR:
;
; Paolo Grigis, SAO, pgrigis@cfa.harvard.edu
; 
; MODIFICATION HISTORY:
;
; 27-FEB-2008 written PG
;-


PRO pg_sortintervals,in,out,sorted_in=sorted_in,sorted_out=sorted_out

  nin=n_elements(in)
  nout=n_elements(out)


  i=0L
  j=0L
  removeindin=-1L
  removeindout=-1L

  WHILE i LT nin-1 AND j LT nout-1 DO BEGIN 

     ;IF i MOD 100 EQ 0 THEN print,i,j


     thisin=in[i]
     nextin=in[i+1]
     thisout=out[j]
     nextout=out[j+1]

     i++
     j++

     IF nextin LE thisout THEN BEGIN       
        WHILE in[i] LE thisout DO BEGIN 
           removeindin=[removeindin,i]
           i++
           IF i EQ nin-1 THEN BREAK
        ENDWHILE         
        nextin=in[i]
     ENDIF

     IF nextout LT nextin THEN BEGIN 
        
        WHILE out[j] LT nextin DO BEGIN
           removeindout=[removeindout,j-1]
           j++
           IF j EQ nout-1 THEN BREAK
        ENDWHILE
     ENDIF

  ENDWHILE



;     print,removeindin
;     print,removeindout
;     print,'---'


IF n_elements(removeindin) GT 1 THEN BEGIN 
   removeindin=removeindin[1:n_elements(removeindin)-1]
   index=cmset_op(lindgen(nin),'AND',/not2 ,removeindin)
   sorted_in=in[index]
ENDIF ELSE sorted_in=in

IF n_elements(removeindout) GT 1 THEN BEGIN 
   removeindout=removeindout[1:n_elements(removeindout)-1]
   index=cmset_op(lindgen(nout),'AND',/not2 ,removeindout)
   sorted_out=out[index]
ENDIF ELSE sorted_out=out


END



