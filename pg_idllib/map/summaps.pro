;+
;
; NAME:
;        summaps
;
; PURPOSE: 
;
;        from an array of (pointers to) map objects, generate a map
;        object with the sum of all the data and an average time
;        The routine DOES assume that all the maps have the same
;        region of the sun, pixel size, image size ecc...      
;        Null pointers in the input array are allowed, but there
;        should be at least a non null pointer. 
;
; CALLING SEQUENCE:
;
;        map=summaps(ptr,min=min,max=max)
; 
; INPUTS:
;
;        ptr: a pointer array. Each pointer should either point to a map
;             object or be a null pointer
;
;        min,max: limit the ranges of maps to sum togheter
;        noaverage: if set, the time of the returned map is equal to
;        the time of the first map taken, else the time is the average
;        time of all the map summed (which in general will be
;        different from 1/2*(time first image + time last image) if
;        there are null pointers in ptr)
;                
; OUTPUT:
;        map: a map consisting of the sum of the input maps
;
;
; VERSION HISTORY:
;       
;       NOV-2002 written
;       5-DEC-2002 imported in rapp_idl, added averaging of time
;       27-JAN-2002 now returns -1 instead of crashing if the pointer
;                   array does not contain any valid pointer
;       30-JAN-2002 now also work with a single pointer as input 
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;-

FUNCTION summaps,ptr,min=min,max=max,noaverage=noaverage

IF (size(ptr))[0] EQ 0 THEN RETURN,*ptr


;if min does not exist find the first pointer not null
;and take the map it points to as the starting map
IF not exist(min) THEN BEGIN
    min=0
    WHILE (min LT (size(ptr))[1]) DO $
      IF ptr[min] EQ ptr_new() THEN min=min+1 ELSE BREAK
ENDIF ELSE BEGIN
    low=0
    WHILE ptr[low] EQ ptr_new() DO low=low+1
    min=max([low,min])
ENDELSE

IF not exist(max) THEN max=(size(ptr))[1]-1

IF min GT max THEN RETURN,-1

data=(*ptr[min]).data
meantime=anytim((*ptr[min]).time)
n_images=1


;addition loop
FOR i=min+1,max DO BEGIN
    IF ptr[i] NE ptr_new() THEN BEGIN
        data=data+(*ptr[i]).data
        meantime=meantime+anytim((*ptr[i]).time)
        n_images=n_images+1
    ENDIF
ENDFOR

map=*ptr[min]
map.data=data

IF NOT keyword_set(noaverage) THEN $
map.time=anytim(meantime/n_images,/yohkoh)


RETURN,map

END
