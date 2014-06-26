;+
; NAME:
;
; pg_plot_disconnected
;
; PURPOSE:
;
; override for the utplot routine, which allows one to plot a function
; with several disconnected parts (otherwise plot joins the points
; over the disconnession)
;
; CATEGORY:
;
; general plotting utility
;
; CALLING SEQUENCE:
;
; pg_plot_disconnected,x,y,ind=ind [,all keyword accepted by plot]
;
; INPUTS:
;
; x,y: like in normal plot
; ind: (dis)-connession indices: they mark when x has jumps
;
; OPTIONAL KEYWORDS:
; 
;
;
; OUTPUTS:
;
; 
;
; OPTIONAL OUTPUTS:
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
; AUTHOR:
;
; Paolo Grigis, Institute of Astronomy, ETH Zurich
; pgrigis@astro.phys.ethz.ch
;
; MODIFICATION HISTORY:
;
; 18-FEB-2004 written
;
;-

PRO pg_utplot_disconnected,x,y,t,ind=ind,timerange=timerange $
   ,MAX_VALUE=max_value, MIN_VALUE=min_value,NSUM=nsum,POLAR=polar,THICK=thick $
   ,CLIP=clip,COLOR=color,LINESTYLE=linestyle,NOCLIP=noclip,PSYM=psym,SYMSIZE=symsize $
   ,T3D=t3d,ZVALUE=zvalue $
   ,xrange=xrange,yrange=yrange,_extra=_extra

IF n_elements(ind) EQ 0 THEN ind=pg_get_connession_index(x)

IF ind[0] EQ -1 THEN BEGIN
   utplot,x,y,t,timerange=timerange $
   ,MAX_VALUE=max_value, MIN_VALUE=min_value,NSUM=nsum,POLAR=polar,THICK=thick $
   ,CLIP=clip,COLOR=color,LINESTYLE=linestyle,NOCLIP=noclip,PSYM=psym,SYMSIZE=symsize $
   ,T3D=t3d,ZVALUE=zvalue $
   ,xrange=xrange,yrange=yrange,_extra=_extra 
ENDIF ELSE BEGIN
   n=n_elements(ind)
   last=n_elements(x)-1

   IF NOT keyword_set(xrange) THEN xrange=[min(x),max(x)]
   IF NOT keyword_set(yrange) THEN yrange=[min(y),max(y)]
 
   utplot,x[0:ind[0]],y[0:ind[0]],t,timerange=timerange $
   ,MAX_VALUE=max_value, MIN_VALUE=min_value,NSUM=nsum,POLAR=polar,THICK=thick $
   ,CLIP=clip,COLOR=color,LINESTYLE=linestyle,NOCLIP=noclip,PSYM=psym,SYMSIZE=symsize $
   ,T3D=t3d,ZVALUE=zvalue $
   ,xrange=xrange,yrange=yrange,_extra=_extra 



   FOR i=1,n-1 DO BEGIN
      outplot,x[ind[i-1]+1:ind[i]],y[ind[i-1]+1:ind[i]],t $
      ,NSUM=nsum,POLAR=polar,THICK=thick $
      ,CLIP=clip,COLOR=color,LINESTYLE=linestyle,NOCLIP=noclip,PSYM=psym,SYMSIZE=symsize $
      ,T3D=t3d
   ENDFOR
   

   outplot,x[ind[n-1]+1:last],y[ind[n-1]+1:last],t $
   ,NSUM=nsum,POLAR=polar,THICK=thick $
   ,CLIP=clip,COLOR=color,LINESTYLE=linestyle,NOCLIP=noclip,PSYM=psym,SYMSIZE=symsize $
   ,T3D=t3d


ENDELSE 


END





