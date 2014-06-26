;+
; NAME:
;
; pg_align2im
;
; PURPOSE:
;
; returns the shift between two images
;
; CATEGORY:
;
;
;
; CALLING SEQUENCE:
;
; xyoffset=pg_align2im(im1,im2,nsquare=nsquare)
;
; INPUTS:
;
;  im1,im2: two 2-dimensional images
;
; OPTIONAL INPUTS:
;
;
; KEYWORD PARAMETERS:
;
;
;
; OUTPUTS:
;
; xyoffset= array of two elements, the x and y offset in pixels between the
;           images. This is the offset of the second image relative to the first.
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
; Paolo Grigis, pgrigis@cfa.harvard.edu
; 
; MODIFICATION HISTORY:
;
;-


FUNCTION pg_align2im,im1in,im2in,nsquare=nsquare,mask=mask

  IF n_elements(nsquare) EQ 0 THEN nsquare=2

  s1=size(im1in)
  s2=size(im2in)

  IF s1[0] NE 2 OR s2[0] NE 2 THEN BEGIN 
     print,'Invalid input'
     return,[!values.f_nan,!values.f_nan]
  ENDIF

  IF total(abs(s1[1:2]-s2[1:2])) NE 0 THEN BEGIN 
     print,'Invalid input'
     return,[!values.f_nan,!values.f_nan]
  ENDIF


  IF keyword_set(mask) THEN BEGIN 
 
     nx=s1[1]
     ny=s1[2]
     x=findgen(nx)-nx/2
     y=findgen(ny)-nx/2         
     xx=x#(x*0+1) 
     yy=(y*0+1)#y
     rr=sqrt(xx*xx+yy*yy)
     themask=(1-rr/(nx-5))>0

     ;protect input, multiply mask
     im1=im1in*themask
     im2=im2in*themask
 
     cc=pg_2dimfftcorr(im1,im2,/norm) 

  ENDIF $
  ELSE BEGIN 
     cc=pg_2dimfftcorr(im1in,im2in,/norm) 
  ENDELSE




  xyoffset=pg_fit2dimparpeak(cc,nsquare=nsquare)-[s1[1]/2,s1[2]/2]

  RETURN,xyoffset

END




