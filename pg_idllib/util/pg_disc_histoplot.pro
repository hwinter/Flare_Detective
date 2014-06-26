;+
; NAME:
;
; pg_disc_histoplot
;
; PURPOSE:
;
; plot an histogram, works also for non contigous bins
;
; CATEGORY:
;
; various utilities
;
; CALLING SEQUENCE:
;
; 
;
; INPUTS:
;
; x_edges: x edges values of the bins
; histo: histogram values
;
; OPTIONAL INPUTS:
;
;
; 
; KEYWORD PARAMETERS:
;
; overplot: overplots
;
;
; OUTPUT:
;
;
; NONE
;
; OPTIONAL OUTPUTS:
;
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
; AUTHOR:
;
; Paolo Grigis, Institute of Astronomy, ETH Zurich
; pgrigis@astro.phys.ethz.ch
;
; MODIFICATION HISTORY:
;
;
; 07-SEP-2004 written P.G.
;
;-


PRO pg_disc_histoplot,x_edges,histo,overplot=overplot,xrange=xrange,yrange=yrange $
                     ,psym=psym,thick=thick,linestyle=linestyle,_extra=_extra

IF NOT keyword_set(overplot) THEN BEGIN

   xrange=fcheck(xrange,[min(x_edges),max(x_edges)])
   yrange=fcheck(yrange,[0,max(histo)])


   plot,[0,0],[0,0],/nodata,xrange=xrange,yrange=yrange,_extra=_extra

ENDIF


;sort x_edges

sortind=sort(x_edges[0,*])
sedges=x_edges[*,sortind]

xr1=min(!X.crange)
xr2=max(!X.crange)
yr1=min(!Y.crange)
;yr2=max(!Y.crange)


oplot,[xr1,min(sedges[*,0])],[yr1,yr1],thick=thick,linestyle=linestyle
oplot,min(sedges[*,0])*[1,1],[yr1,histo[0]],thick=thick,linestyle=linestyle
oplot,[min(sedges[*,0]),max(sedges[*,0])],histo[0]*[1,1],thick=thick,linestyle=linestyle
oplot,max(sedges[*,0])*[1,1],[histo[0],yr1],thick=thick,linestyle=linestyle

FOR i=1,n_elements(histo)-1 DO BEGIN
   oplot,[max(sedges[*,i-1]),min(sedges[*,i])],[yr1,yr1],thick=thick,linestyle=linestyle
   oplot,min(sedges[*,i])*[1,1],[yr1,histo[i]],thick=thick,linestyle=linestyle
   oplot,[min(sedges[*,i]),max(sedges[*,i])],histo[i]*[1,1],thick=thick,linestyle=linestyle
   oplot,max(sedges[*,i])*[1,1],[histo[i],yr1],thick=thick,linestyle=linestyle
ENDFOR

oplot,[max(sedges[*,n_elements(histo)-1]),xr2],yr1*[1,1],thick=thick,linestyle=linestyle


return

END
