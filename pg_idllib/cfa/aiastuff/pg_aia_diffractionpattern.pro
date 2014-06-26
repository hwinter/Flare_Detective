;+
; NAME:
;
; pg_aia_diffractionpattern
;
; PURPOSE:
;
; build a diffraction pattern for aia based on channel information
;
; CATEGORY:
;
; aia calibration
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
; final version Paolo Grigis 2011/06/16
;-

FUNCTION pg_aia_diffractionpattern,meshinfo=meshinfo, $
         PSFEntranceFilter=PSFEntranceFilter, $
         PSFFocalPlane=PSFFocalPlane


psf=dblarr(4096,4096)

wx=4.5;this is the width applied to the Gaussian such that *after* convolution
wy=4.5;I have the proper width (which is 4/3 at 1/e of max)


x=findgen(4096)+0.5
y=x

xx=x#(x*0+1)
yy=(y*0+1)#y

d=meshinfo.spacing
dx1=meshinfo.spacing*cos(meshinfo.angle1/180*!pi)
dy1=meshinfo.spacing*sin(meshinfo.angle1/180*!pi)

dx2=meshinfo.spacing*cos(meshinfo.angle2/180*!pi)
dy2=meshinfo.spacing*sin(meshinfo.angle2/180*!pi)

dx3=meshinfo.spacing*cos(meshinfo.angle3/180*!pi)
dy3=meshinfo.spacing*sin(meshinfo.angle3/180*!pi)

dx4=meshinfo.spacing*cos(meshinfo.angle4/180*!pi)
dy4=meshinfo.spacing*sin(meshinfo.angle4/180*!pi)

meshratio=meshinfo.meshpitch/meshinfo.meshwidth
k=1.0/(meshratio*d)

dpx=0.5
dpy=0.5


;effect from entrance
FOR j=-100,100 DO BEGIN 

   IF j NE 0 THEN BEGIN 

      print,'Fist pass wide angle',j

      intensity=(pg_sinc(j*d*k))^2

      xc=2048.0+dx1*j+dpx
      yc=2048.0+dy1*j+dpy
      psf+=exp(-wx*(xx-xc)^2-wy*(yy-yc)^2)*intensity

      xc=2048.0+dx2*j+dpx
      yc=2048.0+dy2*j+dpy
      psf+=exp(-wx*(xx-xc)^2-wy*(yy-yc)^2)*intensity

      xc=2048.0+dx3*j+dpx
      yc=2048.0+dy3*j+dpy
      psf+=exp(-wx*(xx-xc)^2-wy*(yy-yc)^2)*intensity

      xc=2048.0+dx4*j+dpx
      yc=2048.0+dy4*j+dpy
      psf+=exp(-wx*(xx-xc)^2-wy*(yy-yc)^2)*intensity

   ENDIF 

ENDFOR 


;gets center part
psf=psf/total(psf)*0.18
psf2=exp(-wx*(xx-2048.0-dpx)^2-wy*(yy-2048.0-dpy)^2)
psf2=psf2/total(psf2)*0.82
PSFEntranceFilter=psf2+psf



;get focal plane part
psf=dblarr(4096,4096)


d=meshinfo.fp_spacing

meshratio=meshinfo.meshpitch/meshinfo.meshwidth
k=1.0/(meshratio*d)


dx1=d*cos(45.0/180*!pi)
dy1=d*sin(45.0/180*!pi)

dx2=d*cos(-45.0/180*!pi)
dy2=d*sin(-45.0/180*!pi)

dpx=0.5
dpy=0.5

FOR j=1,100 DO BEGIN 

      print,j

      intensity=(pg_sinc(j*d*k))^2


      xc=2048.0+dx1*j+dpx
      yc=2048.0+dy1*j+dpy
      psf+=exp(-wx*(xx-xc)^2-wy*(yy-yc)^2)*intensity

      xc=2048.0+dx2*j+dpx
      yc=2048.0+dy2*j+dpy
      psf+=exp(-wx*(xx-xc)^2-wy*(yy-yc)^2)*intensity

      xc=2048.0-dx1*j+dpx
      yc=2048.0-dy1*j+dpy
      psf+=exp(-wx*(xx-xc)^2-wy*(yy-yc)^2)*intensity


      xc=2048.0-dx2*j+dpx
      yc=2048.0-dy2*j+dpy
      psf+=exp(-wx*(xx-xc)^2-wy*(yy-yc)^2)*intensity

ENDFOR 


;gets center part
psf=psf/total(psf)*0.18
psf2=exp(-wx*(xx-2048.0-dpx)^2-wy*(yy-2048.0-dpy)^2)
psf2=psf2/total(psf2)*0.82
PSFFocalPlane=psf2+psf


psfnew=shift(abs(fft(fft(PSFFocalPlane)*fft(PSFEntranceFilter),-1)),2048,2048)

psfnew=psfnew/total(psfnew)

return,psfnew



END 
