;+
;
; NAME:
;        map_flux_plot
;
; PURPOSE: 
;        plot the total flux in a series of maps
;      
;
; CALLING SEQUENCE:
;
;        map_flux_plot,ptr
;
; INPUTS:
;        ptr: array of pointers to map
;
; KEYWORDS:
;        onlypositive: set the negative element of the array to 0
;                
; OUTPUT:
;        a plot
; CALLS:
;        utplot
;
; VERSION:
;       
;        24-JAN-2003 imported in rapp_idl, cleaned up
;        28-JAN-2003 added null pointer check
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;-

PRO map_flux_plot,ptr,onlypositive=onlypositive

n=n_elements(ptr)
time=dblarr(n)
flux=dblarr(n)

FOR i=0,n-1 DO BEGIN

    IF ptr[i] NE ptr_new() THEN BEGIN
        map=*ptr[i]
        IF keyword_set(onlypositive) THEN  data=map.data > 0 $
        ELSE  data=map.data
        
        flux[i]=total(data)
        time[i]=anytim(map.time)
    ENDIF
ENDFOR

utplot,time,flux
;plot,time,flux

END

