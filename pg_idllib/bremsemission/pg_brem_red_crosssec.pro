;+
; NAME:
;      pg_brem_red_crosssec
;
; PURPOSE: 
;      returns the reduced bremsstralung cross section
;      Implemeted approximations: Kramers, Bethe-Heitler 
;
; CALLING SEQUENCE:
;      f_brem_red_crossec,phe,ele
;
; INPUTS:
;      phe: photon energy, only one value allowed
;           (if array is put in, then the 0th element is taken)
;      ele: electron energy, can be an array
;
; KEYWORDS:
;      kramers: select Kramers cross section
;      bh: select Bethe-Heitler cross section (default)
;
; OUTPUT:
;      cross section
;       
;
; COMMENT:
;
;
; EXAMPLE   
;
;
;
; VERSION:
;       28-SEP-2005 written PG
;       17-OCT-2005 fixed ele indexing bug 
;       
; AUTHOR:
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;-

FUNCTION pg_brem_red_crosssec,phe,ele,kramers=kramers,bh=bh,_extra=_extra

e=phe[0]

IF keyword_set(kramers) THEN BEGIN
   res=ele*0.
   ind=where(ele GE e,count)
   IF count GT 0 THEN res[ind]=1.
ENDIF $
ELSE BEGIN 
   res=ele*0.
   ind=where(ele GE e,count)
   IF count GT 0 THEN res[ind]=alog((1+sqrt(1-e/ele[ind]))/(1-sqrt(1-e/ele[ind])))
ENDELSE

RETURN,res

END
