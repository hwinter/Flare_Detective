;+
; NAME:
;
; pg_imtrans
;
; PURPOSE:
;
; shift an image (or image set) by a specified amount 
;
; CATEGORY:
;
; image manip
;
; CALLING SEQUENCE:
;
; imsetshifted=pg_imtrans(imset [,/bilinear,/cubic])
;
; INPUTS:
;
;  imset: either an NX x NY image or an NX x NY x NFRAMES image set
;
; OPTIONAL INPUTS:
;
;
; KEYWORD PARAMETERS:
;
; cubic: Set this keyword to a value between -1 and 0 to use the cubic convolution
;        interpolation method with the specified value as the interpolation parameter.
;        Setting this keyword equal to a value greater than zero specifies a value of -1
;        for the interpolation parameter. Park and Schowengerdt suggest that a value of
;        -0.5 significantly improves the reconstruction properties of this algorithm. 
;
; OUTPUTS:
;
; xyoffset = array of two elements, the x and y offset in pixels between the
;            images. This is the offset of the second image relative to the first.
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
; 04-APR-2008 written PG
;-


FUNCTION pg_imtrans,imset,xyoffset,cubic=cubic
  
  s=size(imset)

  IF NOT(s[0] EQ 2 OR s[0] EQ 3) THEN BEGIN 
     print,'Invalid Input. Please input a 2- or 3-dimensional array'
     RETURN,-1
  ENDIF

  nx=s[1]
  ny=s[2]

  x=findgen(nx)
  y=findgen(ny)

  IF s[0] EQ 2 THEN BEGIN
     shiftedim=interpolate(imset,x+xyoffset[0],y+xyoffset[0],cubic=cubic,/grid)
  ENDIF ELSE BEGIN 
     nim=s[3]
     shiftedim=imset
     FOR i=0,nim-1 DO BEGIN
        shiftedim[*,*,i]=interpolate(imset[*,*,i],x+xyoffset[0,i],y+xyoffset[0,i],cubic=cubic,/grid)
     ENDFOR
  ENDELSE

  RETURN,shiftedim

END




