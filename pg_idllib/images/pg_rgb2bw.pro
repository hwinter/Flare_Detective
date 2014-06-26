;+
; NAME:
;
; pg_rgb2bw
;
; PURPOSE:
;
; convert an rgb image to black and white without gray scales
;
; CATEGORY:
;
; image utilities
;
; CALLING SEQUENCE:
;
; out_im=pg_rgb2bw(in_im)
;
; INPUTS:
;
; in_im: a 3xNxM byte array (RGB image)
;
; OPTIONAL INPUTS:
;
; none
;
; KEYWORD PARAMETERS:
;
; none
;
; OUTPUTS:
;
; out_im: same type as in_im
;
; OPTIONAL OUTPUTS:
;
; none
;
; COMMON BLOCKS:
;
; none
;
; SIDE EFFECTS:
;
; none
;
; RESTRICTIONS:
;
; does not check whether in_im of the right type
;
; PROCEDURE:
;
; checks where im is not [255,255,255] and set this to [0,0,0]
;
; EXAMPLE:
;
;
; 
; AUTHOR:
;
; Paolo Grigis, Institute for Astronomy, ETH Zurich
; pgrigis@astro.phys.ethz.ch
;
; MODIFICATION HISTORY:
;
; 3-DEC-2003 written PG
;
;-
FUNCTION pg_rgb2bw,im

   s=size(im)
   n=s[2]
;  m=s[3]

   ind=where(((im[0,*,*] NE 255B) AND (im[1,*,*] NE 255B) $
              AND (im[2,*,*] NE 255B)),count)

   out_im=im

   IF count GT 0 THEN BEGIN
      indx=ind MOD n            ; two dimensional indices
      indy=ind / n              ; 
      out_im[indx*3+indy*3*n]=0B ;better use 1 dim index for memory reason 
      out_im[1+indx*3+indy*3*n]=0B 
      out_im[2+indx*3+indy*3*n]=0B  
;      out_im[1,indx,indy]=0B
;      out_im[1,indx,indy]=0B     
   ENDIF
   
   RETURN,out_im

END


;testing...

; im=bytarr(3,100,100)
; im[0]=byte(randomu(seed,30000)*12+244)
; tv,im,/true
; ind=where(((im[0,*,*] EQ 255B) AND (im[1,*,*] EQ 255B) $
;               AND (im[2,*,*] EQ 255B)),count)

; tvscl,im,/true
; tvscl,out_im,/true
