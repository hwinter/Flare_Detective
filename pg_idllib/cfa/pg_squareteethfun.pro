;+
; NAME:
;
;  pg_squareteethfun.pro
;
; PURPOSE:
;
; returns a function with "teeths", that is, rectangular shapes as described below:
; (use a fixed width font to see the drawing below, or it won't make any
; sense at all)
;
;  
;  
;        ________      ________      ________
;        |      |      |      |      |      |
;     ___|      |______|      |______|      |___
;                      <------>
;                         b
;            <------------>         
;                  a
;
; CATEGORY:
;
; math util
;
; CALLING SEQUENCE:
;
; f=pg_squareteethfun(x,a=a,b=b)
;
; INPUTS:
;
; x: array of ascissa
; a: "wavelength", i.e. distance from the middle of one crest to the next one (default: 2)
; b: "crest width", i.e. length of the crest (default 1)
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
; f: ascissa
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
;
;
; AUTHOR: 
;
; Paolo Grigis, SAO
; pgrigis@cfa.harvard.edu
;
; MODIFICATION HISTORY:
;
; 09-MAR-2009 written PG
; 
;-

FUNCTION pg_squareteethfun,xin,a=a,b=b

a=fcheck(a,2)
b=fcheck(b,1)

halfa=0.5*a
halfb=0.5*b
halfdiff=halfb-halfa

y=xin*0

xmin=min(xin)

IF xmin LT 0 THEN x=xin+round(abs(xmin)/a+1)*a ELSE x=xin

xmod=(x-halfdiff) MOD a

ind1=where( xmod LE (a-b) )

y[ind1]=1

RETURN,y

END







