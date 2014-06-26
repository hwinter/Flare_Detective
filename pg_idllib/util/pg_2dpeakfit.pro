;+
; NAME:
;
; pg_2dpeakfit
;
; PURPOSE:
;
; wrapper around mpfit2dpeak
; 
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
; KEYWORD PARAMETERS:
;
;
; OUTPUTS:
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
;
;
; AUTHOR:
;
; Paolo Grigis, Institute of Astronomy, ETH Zurich
; pgrigis@astro.phys.ethz.ch
;
; MODIFICATION HISTORY:
;
; 16-SEP-2004 written PG
;-

FUNCTION pg_2dpeakfit,data,x,y,_extra=_extra


   parinfo=replicate({fixed:0,limits:[0,0],limited:[0,0]},7)
   parinfo[6].limited=[1,1]
   parinfo[6].limits=[-4*!DPi,4*!DPi]

   yfit=mpfit2dpeak(data,parms,x,y, /tilt,parinfo=parinfo $
       ,status=status,_extra=_extra)

   return,parms


END
