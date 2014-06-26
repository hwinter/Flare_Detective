;+
; NAME:
;
; pg_rgb2hsi 
;
; PURPOSE:
;
; convert colors from RGB scheme to HSI scheme (forward) and from HSI to RGB (backward)
;
; CATEGORY:
;
; digital image processing
;
; CALLING SEQUENCE:
;
; pg_rgb2hsi,red=red,green=green,blue=blue,hue=hue,saturation=saturation,intensity=intensity
;           [/forward or /backward]
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
; MODIFICATION HISTORY:
;
;-


PRO pg_rgb2hsi,red=red,green=green,blue=blue,hue=hue,saturation=saturation,intensity=intensity,forward=forward,backward=backward


IF keyword_set(backward) THEN BEGIN 
ENDIF

;forward
ElementsOfRGB=[n_elements(red),n_elements(green),n_elements(blue)]
nColors=max(ElementsOfRGB)

IF nColors EQ 0 THEN BEGIN
   print,'Invalid Input! Need 3 arrays red, green, blue'
   return
ENDIF 

R=fltarr(nColors)
R[0]=red/255.0
G=fltarr(nColors)
G[0]=green/255.0
B=fltarr(nColors)
B[0]=Blue/255.0


hue=fltarr(nColors)
saturation=fltarr(nColors)
intensity=fltarr(nColors)

intensity=(r+g+b)/3.0

ind = where(intensity GT 0.0,countIntGreater0)

IF countIntGreater0 THEN BEGIN 

   saturation=1.0-3.0*(R[ind]<G[ind]<B[ind])/(r[ind]+g[ind]+b[ind])

   ;check sat EQ 0

   Theta=acos(0.5*(2*R[ind]-G[ind]-B[ind])/sqrt((R[ind]-G[ind])^2+(R[ind]-B[ind])*(G[ind]-B[ind])))

   Hue[ind]=Theta/(2*!Pi)

   IndBlessG=where(B[ind] GT G[ind],CountBlessG)
   IF CountBlessG GT 0 THEN Hue[ind]=1.0-Hue[ind]

   

ENDIF 


END 


