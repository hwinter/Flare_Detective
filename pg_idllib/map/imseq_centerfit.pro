;+
;
; NAME:
;        imseq_mapcenterfit
;
; PURPOSE: 
;        find the coordinates of the center of an ellipse which can be
;        best fitted to the map object --> for a series of images 
;      
;
; CALLING SEQUENCE:
;
;        cent=imseq_mapcenterfit(ptr,maxfr=maxfr)
; 
;
; INPUTS:
;
;        ptr : a pointer array to map structures
;        maxfr: consider only pixel brighter than maxfr of the maximum
;
; KEYWORDS:
;        ptr2ptr: if used, ptr is treated as an array of pointer to
;                 (array of pointers to map objects). Useful if you
;                 have image sequences in many energy/frequency bands
;        mpfit: if set, uses CM mpfit2dpeak instead of gauss2dfit
;                
; OUTPUT:
;        cent: array with coordinates of the center of the ellipse        
; CALLS:
;        mapcenterfit
;
; VERSION:
;       
;        3-FEB-2003 written
;        4-FEB-2003 ptr2ptr keyword added
;       19-MAR-2003 mpfit keyword added
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;-

FUNCTION imseq_centerfit,ptr,maxfrac=maxfrac,loud=loud,ptr2ptr=ptr2ptr $
                        ,mpfit=mpfit,dontlower=dontlower

IF keyword_set(ptr2ptr) THEN BEGIN

    s=size(ptr)
    IF s[n_elements(s)-2] EQ 10 THEN BEGIN

        n_images=intarr(s[n_elements(s)-1])
        FOR i=0,n_elements(n_images)-1 DO BEGIN
            n_images[i]=n_elements((*ptr[i]))
        ENDFOR
        
        max=max(n_images)

        cent=fltarr(s[n_elements(s)-1],max,2)

        FOR j=0,s[n_elements(s)-1]-1 DO BEGIN
            FOR i=0,n_elements(*ptr[j])-1 DO BEGIN

                IF keyword_set(loud) THEN $
                  print,'Now doing image '+strtrim(i+1,2)+' of sequence '+ $
                         strtrim(j+1,2)
                
                IF (*ptr[j])[i] NE ptr_new() THEN BEGIN
                    cent[j,i,*]=mapcenterfit(*((*ptr[j])[i]),maxfrac=maxfrac,mpfit=mpfit,dontlower=dontlower)
                ENDIF $
                ELSE $
                  cent[j,i,*]=[!values.F_NaN,!values.F_NaN]
                
            ENDFOR
        ENDFOR

        RETURN,cent

        
    ENDIF ELSE RETURN,-1

ENDIF $
ELSE BEGIN

cent=fltarr(n_elements(ptr),2)

FOR i=0,n_elements(ptr)-1 DO BEGIN
    IF keyword_set(loud) THEN $
      print,'Now doing image '+strtrim(i,2) 

    IF ptr[i] NE ptr_new() THEN BEGIN
        cent[i,*]=mapcenterfit(*ptr[i],maxfrac=maxfrac,mpfit=mpfit,dontlower=dontlower) 
    ENDIF $
    ELSE $
      cent[i,*]=[!values.F_NaN,!values.F_NaN]

ENDFOR

RETURN,cent

ENDELSE

END



