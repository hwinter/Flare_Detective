;+
; NAME:
;
; pg_setplotsymbol
;
; PURPOSE:
;
; define some plot symbols (via the usersym mechanism)
;
; CATEGORY:
;
; plot utilities
;
; CALLING SEQUENCE:
;
; pg_getplotsymbol,symbol,size=size
;
; INPUTS:
;
; symbol: a string. Plot symbols available:
;
;         
;
;
;
; size: optional size parameter, default:1
; 
; OPTIONAL INPUTS:
;
; 
; KEYWORD PARAMETERS:
;
;
; OUTPUT:
;
;
; PROCEDURE:
;
;
;
; EXAMPLE:
; 
;
; AUTHOR:
;
; Paolo Grigis, Institute of Astronomy, ETH Zurich
; pgrigis@astro.phys.ethz.ch
;
; MODIFICATION HISTORY:
;
; 18-AUG-2004 written P.G.
; 13-JAN-2006 added DIAMOND option
;
;-

PRO pg_setplotsymbol,symbol,size=size,starfactor=starfactor

size=fcheck(size,1d)
sf=fcheck(starfactor,0.381966d)

CASE strupcase(symbol) OF 
   
   'CIRCLE' : BEGIN
      N=48.
      A = FINDGEN(N) * (!PI*2./(N-1))
      USERSYM, size*COS(A), size*SIN(A), /FILL
   END

   'TRIANGLE' : BEGIN
      xp=size*[0,-cos(30d/180*!DPi),cos(30d/180*!DPi),0]
      yp=size*[1,-sin(30d/180*!DPi),-sin(30d/180*!DPi),1]
      usersym,xp,yp,/fill
   END

   'SQUARE' : BEGIN
      xp=size*[-1,1,1,-1,-1]
      yp=size*[-1,-1,1,1,-1]
      usersym,xp,yp,/fill
   END

   'STAR' : BEGIN
      
      xp=size*[0,-sf*sin(36d/180*!DPi) ,-sin(72d/180*!DPi), $
                 -sf*sin(108d/180*!DPi),-sin(144d/180*!DPi), $
                 -sf*sin(180d/180*!DPi),-sin(216d/180*!DPi), $
                 -sf*sin(252d/180*!DPi),-sin(288d/180*!DPi), $
                 -sf*sin(324d/180*!DPi),0]

      yp=size*[1,sf*cos(36d/180*!DPi) ,cos(72d/180*!DPi), $
                 sf*cos(108d/180*!DPi),cos(144d/180*!DPi), $
                 sf*cos(180d/180*!DPi),cos(216d/180*!DPi), $
                 sf*cos(252d/180*!DPi),cos(288d/180*!DPi), $
                 sf*cos(324d/180*!DPi),1]

      usersym,xp,yp,/fill

   END

   'DIAMOND': BEGIN 

      xp=size*[-1,0,1,0]
      yp=size*[0,1,0,-1]      
      usersym,xp,yp,/fill

   END




ENDCASE


END
