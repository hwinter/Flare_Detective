;+
;
; NAME:
;       vlafitsread3
;
; PROJECT: 
;       radio images handling
;
; PURPOSE: 
;       read a VLA fits file and transform it into a sequence of maps
;
;
; CALLING SEQUENCE:
;       ptr=vlafitsread(filename)
;
; INPUTS:
;       filename: fits filename
;        
;
; OUTPUT:
;       ptr: a pointer to a map or map sequence
;       
; KEYWORDS:
;       ...
;
; RESTRICTIONS:
;
; EXAMPLE:
;        
;
; VERSION:
;       24-MAR-2003 written
;       11-JUN-2003 modified as to accept external ref pixel
;       04-JUL-2003 taken in account last info from Tim
;
; COMMENT:
;       WORKS for 128x128 maps!
;
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;-

FUNCTION vlafitsread3,filename,begtime=begtime,deltatime=deltatime,refx=refx,refy=refy

IF NOT keyword_set(refx) THEN refx=0
IF NOT keyword_set(refy) THEN refy=0

data=mrdfits(filename,0,header)

head_st=fitshead2struct(header)

n=head_st.naxis3      ;number of frames
npixx= head_st.naxis1 ; number of pixels in x direction
npixy= head_st.naxis2 ; number of pixels in y direction

dx=-head_st.cdelt1*3600. ;pixel width in x direction, in arcseconds (positve ->right)
dy=head_st.cdelt2*3600. ;pixel width in x direction, in arcseconds

ref_pix_x=head_st.crpix1 ;reference pixel (x direction) 
ref_pix_y=head_st.crpix2 ;reference pixel (y direction)

;coordinate are mapped in the bottom left corner of the pixel in the
;VLA fits files, but we use a negative x-direction system, such
;that left becomes *effectively* right!! 
;Zarro maps require the center of the image as coordinates and the
;pixel widths

llcx=refx-(ref_pix_x)*dx ;x coord of lower left corner of the image
llcy=refy-(ref_pix_y-1)*dy ;y coord of lower left corner of the image

urcx=refx+(npixx-ref_pix_x)*dx ;x coord of upper right corner of the image
urcy=refx+(npixy-ref_pix_y+1)*dx ;y coord of upper right corner of the image

xc=0.5*(llcx+urcx) ;x coord of the center of the image
yc=0.5*(llcy+urcy) ;y coord of the center of the image

;xc=(head_st.naxis1/2.-head_st.crpix1+0.5)*dx
;yc=(head_st.naxis2/2.-head_st.crpix2+1-0.5)*dy

ptr=ptrarr(n)

IF n_elements(deltatime) EQ 0 THEN deltatime=1
IF n_elements(begtime) EQ 0 THEN begtime=anytim('01-OCT-2002 15:00') $
ELSE begtime=anytim(begtime)

FOR i=0,n-1 DO BEGIN
    map=make_map(data[*,*,i],xc=xc,yc=yc,dx=dx,dy=dy,time=anytim(begtime+i*deltatime,/vms))
    ptr[i]=ptr_new(map)
ENDFOR

RETURN,ptr

END






















