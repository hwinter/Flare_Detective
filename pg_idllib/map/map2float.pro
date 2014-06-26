;+
; NAME:
;       map2float
;
; PURPOSE: 
;       convert a series of map such that map.data is a float
;
; CALLING SEQUENCE:
;       
;       ptrnew=map2float(ptr)
;
; INPUTS:
;       ptr: array of pointers to maps
;
; OUTPUT:
;       the pointer to the corrected images 
;
; HISTORY:
;       10-MAR-2003 written
;
; AUTHOR:
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;-

FUNCTION map2float,ptr

ptrnew=ptr
n=n_elements(ptr)

FOR i=0,n-1 DO BEGIN
    IF ptr[i] NE ptr_new() THEN BEGIN

        mapint=*ptr[i]
        data=float(mapint.data)
        map=create_struct('data',data)
        nel=n_tags(mapint)
        names=tag_names(mapint)
        FOR j=1,nel-1 DO BEGIN
            map=create_struct(map,names[j],mapint.(j))           
        ENDFOR
        
        ptrnew[i]=ptr_new(map)
    ENDIF

;(*ptrnew[i]).data=float((*ptr[i]).data) 

ENDFOR

RETURN,ptrnew

END
