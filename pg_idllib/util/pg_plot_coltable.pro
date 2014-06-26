;+
; NAME:
;
; pg_plot_coltable
;
; PURPOSE:
;
; plots the actual color table with the numbers nicely labeled
;
; CATEGORY:
;
; utilties (color)
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
;
;
; AUTHOR:
; Paolo Grigis, Institute for Astronomy, ETH Zurich
; pgrigis@astro.phys.ethz.ch
;
; MODIFICATION HISTORY:
;
; 16-DEC-2004 written
;
;-

PRO pg_plot_coltable


   tvlct,r,g,b,/get

   wdef,1,768,768
   testim=congrid(bindgen(16,16),768,768)
   tv,testim
   
   r2=r
   g2=g
   b2=b
   r2[0]=0B
   g2[0]=0B
   b2[0]=0B
   r2[255]=255B
   g2[255]=255B
   b2[255]=255B
   tvlct,r2,g2,b2

   oldp=!P
   !P.font=-1

   FOR i=0,16 DO FOR j=0,16 DO BEGIN
      xyouts,i*48-16,j*48+16,string(i+j*16),/device,color=0,charthick=5
      xyouts,i*48-16,j*48+16,string(i+j*16),/device,color=255,charthick=1
   ENDFOR

   tvlct,r,g,b,/get

   !P=oldp
  
END
