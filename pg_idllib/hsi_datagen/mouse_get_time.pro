;+
; NAME:
;   mouse_get_time
;
; PURPOSE:
;   return the time coordinate of the cursor over a preexisting utplot    
;
; INPUT: 
;   time0: basetime for the utplot
;
; KEYWORDS:
;   kilo: convert seconds in milliseconds for use with anytim  
;   noanytim: don't use anytim
;-

PRO mouse_get_time,time0=time0,kilo=kilo,noanytim=noanytim

!mouse.button=0

WHILE (!mouse.button NE 4) DO BEGIN
   cursor,x,y,/data,/down
   IF exist(kilo) THEN $
      print,anytim(time0+(1000*x),/yohkoh) $
   ELSE IF exist(noanytim) THEN  print,x $
      ELSE print,anytim(time0+x,/yohkoh)
ENDWHILE

END
