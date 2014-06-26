;+
; NAME:
;
; pg_corrtrack
;
; PURPOSE:
;
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
; 15-JUL-2010 Paolo Grigis
;
;-

PRO pg_corrtrack,d1,d2,nx=nx,ny=ny,nsquare=nsquare,xx=xx,yy=yy

size1=size(d1)
size2=size(d2)

imxsize=size1[1]
imysize=size1[2]

nsquare=fcheck(nsquare,10)

nx=fcheck(nx,16)
nbins=imxsize/nx

ny=fcheck(ny,16)
nbins=imysize/ny

xx=fltarr(nbins,nbins)
yy=fltarr(nbins,nbins)

FOR i=0,nbins-1 DO BEGIN 
   FOR j=0,nbins-1 DO BEGIN 
      im1=d1[i*nx:i*nx+nx-1,j*ny:j*ny+ny-1]
      im2=d2[i*nx:i*nx+nx-1,j*ny:j*ny+ny-1]
      xyoffset=pg_align2im(im1,im2,nsquare=nsquare)
      xx[i,j]=xyoffset[0]
      yy[i,j]=xyoffset[1]
   ENDFOR 
ENDFOR


END


