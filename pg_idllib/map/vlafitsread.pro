;+
;
; NAME:
;       vlafitsread
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
; OUTPUT:
;       ptr: a pointer to a map or map sequence
;       
; KEYWORDS:
;       ...
;
; EXAMPLE:
;        
;
; VERSION:
;       24-MAR-2003 written
;
;
; COMMENT:
;       WORKS for 128x128 maps!
;
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;-

FUNCTION vlafitsread,filename,begtime=begtime,deltatime=deltatime

data=mrdfits(filename,0,header)

head_st=fitshead2struct(header)

n=head_st.naxis3
npixx= head_st.naxis1
npixy= head_st.naxis2

dx=abs(head_st.cdelt1*3600.)
dy=head_st.cdelt2*3600.

xc=(head_st.naxis1/2.-head_st.crpix1+0.5)*dx
yc=(head_st.naxis2/2.-head_st.crpix2+1-0.5)*dy

ptr=ptrarr(n)

IF n_elements(deltatime) EQ 0 THEN deltatime=0
IF n_elements(begtime) EQ 0 THEN begtime=anytim('01-OCT-2002 15:00') $
ELSE begtime=anytim(begtime)

FOR i=0,n-1 DO BEGIN
    map=make_map(data[*,*,i],xc=xc,yc=yc,dx=dx,dy=dy,time=anytim(begtime+i*deltatime,/vms))
    ptr[i]=ptr_new(map)
ENDFOR

RETURN,ptr

END






















