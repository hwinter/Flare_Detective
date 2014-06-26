;+
;
; NAME:
;        pg_intmap
;
; PURPOSE: 
;
;        from an array of (pointers to) map objects, generate a map
;        object with the sum of all the data and an average time
;        The routine DOES assume that all the maps have the same
;        region of the sun, pixel size, image size ecc...      
;        The maps are differentially rotated before being added
;        together
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
;
;                
; OUTPUT:
;        map: a map consisting of the sum of the input maps
;
;
; VERSION HISTORY:
;       
;       NOV-2002 written
;       5-DEC-2002 imported in rapp_idl, added averaging of time
;       27-JAN-2003 now returns -1 instead of crashing if the pointer
;                   array does not contain any valid pointer
;       30-JAN-2003 now also work with a single pointer as input 
;       04-APR-2005 renamed pg_intmap, added differential rotation
;                    correction
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;-

FUNCTION pg_intmap,ptr,min=min,max=max

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

starttime=anytim((*ptr[min]).time)
meantime=0.;starttime
n_images=1

;get average time
FOR i=min+1,max DO BEGIN
    IF ptr[i] NE ptr_new() THEN BEGIN
;        data=data+(*ptr[i]).data
        meantime=meantime+(anytim((*ptr[i]).time)-starttime)
        n_images=n_images+1
    ENDIF
ENDFOR


meantime=starttime+meantime/n_images

data=(*ptr[min]).data
data[*]=0.

;integrate the maps together
FOR i=min,max DO BEGIN
    print,i
    IF ptr[i] NE ptr_new() THEN BEGIN
       map=*ptr[i]
       drotmap=drot_map(map,time=meantime)
       data=data+drotmap.data
    ENDIF
ENDFOR

mapfinal=*ptr[min]
mapfinal.time=anytim(meantime,/vms)


;map=*ptr[min]
;map.data=data;
;map.time=anytim(starttime+meantime/n_images,/vms)


RETURN,mapfinal

END
