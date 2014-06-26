;+
; NAME:
;   togoes
;
; PURPOSE:
;   transform a flux in the standard goes format (e.g. M2.5)    
;
; INPUT: 
;   flux: goes flux in watt/m^2
;
; KEYWORDS:
;   invert: transform 'M2.5' in flux
;
;
; $Id: togoes.pro 5 2007-12-04 21:15:49Z pgrigis $
;
; HISTORY:
;   written 02-DEC-2002 by Paolo Grigis
;   06-DEC-2002 rewritten: simplified using string formatted output       
;   03-JUL-2003 added /invert functionality
;-


FUNCTION togoes,flux,invert=invert

IF keyword_set(invert) THEN BEGIN

firstl=strmid(flux,0,1)
rest=strmid(flux,1)

CASE firstl OF ;BEGIN

    'A' : res=double(rest)*1d-8
    'B' : res=double(rest)*1d-7
    'C' : res=double(rest)*1d-6
    'M' : res=double(rest)*1d-5
    'X' : res=double(rest)*1d-4

   ELSE : res=double(flux)

ENDCASE

RETURN,res

ENDIF ELSE BEGIN
IF flux LE 0       THEN RETURN,string(flux,'(e8.1)') ; negative flux
IF flux GE 9.95d-3 THEN RETURN,string(flux,'(e7.1)') ; greater than X99
IF flux LT 9.95d-9 THEN RETURN,string(flux,'(e7.1)') ; less than A1.0

;The remaining fluxes needs to be converted to the GOES notation
;attention: 9.97e-6 needs to be simplified to M1.0 and similar problems!

goesletter=['A','B','C','M','X']

logf=floor(alog10(flux))


IF flux LT 9.95d-4 THEN BEGIN ;less than X10

    str=string(flux/10d^(logf),'(e7.1)')

    ;print,str
    ;print,logf

    IF strmid(str,6,1) EQ 0 THEN $ ;normal case
         str=goesletter[8+logf]+strmid(str,0,3) $
    ELSE $                         ;9.97e-xx case
         str=goesletter[9+logf]+strmid(str,0,3)

ENDIF $
ELSE BEGIN   ; between X10 and X99
    IF flux GE 1d-3 THEN $ 
         str='X'+strtrim(string(round(flux/10d^(logf-1))),2) $
    ELSE $   ;greater than 9.95e-4 and less than 1e-3
         str='X10'
ENDELSE

RETURN,str

ENDELSE

END

