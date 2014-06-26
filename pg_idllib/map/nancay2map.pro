;+
;
; NAME:
;        nancay2map
;
; PURPOSE: 
;
;        from a given nancay fit file produces (Zarro) map objects       
;
; CALLING SEQUENCE:
;
;        ptr=nancay2map(filename)
; 
; INPUTS:
;
;        filename: the filename of a Nancay fit file
;                
; OUTPUT:
;        ptr: array of pointer to map objects
;
; CALLS:
;       mrdfits,anytim,fits2map,get_sun
;
; VERSION:
;       
;       4-DEC-2002 written
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;-

FUNCTION nancay2map,filename


;filename='~/data/nancay/nrh2_3270_h80_20021001_143046c08_i.fts'

imcube=mrdfits(filename,1,h) ;read the nancay images

info=fitshead2struct(h) ;information about the observation

hourstart=info.tim_str  ;start of observation
hourend=info.tim_end    ;end of observation

strput,hourstart,'.',8  ;changes ':' to '.' for compatibility
strput,hourend,'.',8    ;with formats accepted by anytim 

times=anytim(info.date_d$obs+' '+hourstart) ;add the observing date
timee=anytim(info.date_d$obs+' '+hourend)   ;

timemed=0.5*(times+timee) ; middle observation time, used as a referece time      

sunpar=get_sun(timemed)   ; 
radius=sunpar[1]          ;this gives the solar radius at timemed in arcseconds

;sizex=info.crpix1     ;size of the images, not needed
;sizey=info.crpix2     ;

pixradius=info.solar_r ;radius of the sun, in pixels

dx=radius/pixradius    ;arcseconds width of the pixels
dy=radius/pixradius    ;


;now can proceed to transform the images in map objects

dim=size(imcube)       

ptr=ptrarr(dim[1])

FOR i=0,dim[1]-1 DO BEGIN
    
    time=anytim(anytim(info.date_d$obs)+imcube[i].time/1000d,/yohkoh)
    
    map=make_map(imcube[i].stokesi,dx=dx,dy=dy,time=time)

    ptr[i]=ptr_new(map)

ENDFOR

RETURN,ptr

END


