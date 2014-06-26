;+
;
; NAME:
;        pg_plot_multi_color
;
; PURPOSE: 
;
;        plots data with different colors on different intervals
;
; CALLING SEQUENCE:
;
;        plot,x,y,border_indices
;        [,color_indices=color_indices ,/utplot] ;optional
;        [, graphics keywords] ;optional
; 
; INPUTS:
;
;        x,y: scatter data
;        border_indices: array [0..2N] of indices
;        color_indices: array [0..N] of colors, dafult to 1,2,3,...,N
;
; KEYWORDS:
;        utplot: uses utplot instead of plot
;        noplot: only make the overplotting part
;        accept all keyword accepted by plot
;                
; OUTPUT:
;        none
;
; CALLS:
;       plot (utplot optionally)
;
; EXAMPLE:
; 
;        a=findgen(1000)+1
;        bor=reform(transpose([[100*indgen(10)],[100*(indgen(10)+1)]]),20)
;        col=indgen(10)
;        pg_plot_multi_color,a,a*a,bor,color_indices=col+1
;
; VERSION:
;       
;       29-SEP-2003 written
;       30-SEP-2003 changed, now also works if color indices has less
;       elements then 0.5*n_elements(border_indices)
;       01-OCT-2003 added noplot keyword
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;-

PRO pg_plot_multi_color,x,y,border_indices,color_indices=color_indices $
                       ,utplot=utplot,noplot=noplot,_extra=_extra

n=n_elements(border_indices)/2

IF NOT keyword_set(noplot) THEN BEGIN
    IF NOT keyword_set(utplot) THEN $
        plot,x,y,_extra=_extra ELSE $
        utplot,x-x[0],y,x[0],_extra=_extra
ENDIF

IF n_elements(color_indices) EQ 0 THEN color_indices=indgen(n)+1
IF n_elements(color_indices) LT n THEN BEGIN
    tmparr=indgen(n-n_elements(color_indices))+1
    color_indices=[color_indices,tmparr]
ENDIF
;IF n_elements(color_indices) EQ 1 THEN color_indices=replicate(color_indices,n)


FOR i=0,n-1 DO BEGIN
    indarr=border_indices[2*i]+indgen(border_indices[2*i+1] $
          -border_indices[2*i]+1)
    IF NOT keyword_set(utplot) THEN $
        oplot,x[indarr],y[indarr],color=color_indices[i] ELSE $
        outplot,x[indarr]-x[0],y[indarr],x[0],color=color_indices[i]

ENDFOR

END












