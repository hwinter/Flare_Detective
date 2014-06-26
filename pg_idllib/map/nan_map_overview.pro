;+
;
; NAME:
;        nan_map_overview
;
; PURPOSE: 
;
;        plot an overview of nancay data in the 5 frequencies available
;
; CALLING SEQUENCE:
;
;        nan_map_overview,filename=filename,time_range=time_range,ptr=ptr
; 
; INPUTS:
;
;        filename : the filename of the output plot
;        time_range : time range over whicch images are to be taken,
;        not yet implemented
;        cent: center poitions to be plotted
;                
; OUTPUT:
;        a plot 
;
; CALLS:
;      
;
; VERSION:
;       
;       3-FEB-2002 written
;       4-FEB-2002 added cent option
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;-

PRO nan_map_overview,filename=filename,ptr=ptr,maxfrac=maxfrac,cent=cent,_extra=_extra,totcenter=totcenter;,time_range=time_range

ptr164=(*ptr[0])
ptr236=(*ptr[1])
ptr327=(*ptr[2])
ptr410=(*ptr[3])
ptr432=(*ptr[4])

; IF NOT keyword_set(time_range) THEN BEGIN
;     time_range=[anytim((*ptr164[0]).time),anytim((*ptr164[n_elements(ptr164)-1]).time)]
; ENDIF

tm164=summaps(ptr164)
tm236=summaps(ptr236)
tm327=summaps(ptr327)
tm410=summaps(ptr410)
tm432=summaps(ptr432)

IF exist(maxfrac) THEN BEGIN

cen164=mapcenterfit(tm164,maxfrac=maxfrac)
cen236=mapcenterfit(tm236,maxfrac=maxfrac)
cen327=mapcenterfit(tm327,maxfrac=maxfrac)
cen410=mapcenterfit(tm410,maxfrac=maxfrac)
cen432=mapcenterfit(tm432,maxfrac=maxfrac)

ENDIF ELSE BEGIN
cen164=mapcenterfit(tm164)
cen236=mapcenterfit(tm236)
cen327=mapcenterfit(tm327)
cen410=mapcenterfit(tm410)
cen432=mapcenterfit(tm432)
ENDELSE


oldp=!P
set_plot,'ps'
device,filename=filename,ysize=25.2,yoffset=2,xsize=18,xoffset=1

!P.MULTI=[0,2,3]

plot_map,tm164,title='Nancay map 164 MHz',/contour,/percent, $
         levels=[10,20,30,40,50,60,70,80,90],/limb,lmcolor=0, $
         xrange=[-1024,1024],yrange=[-1024,1024],_extra=_extra

IF exist(cent) THEN BEGIN
oplot,[cent[0,*,0]],[cent[0,*,1]],psym=1
ENDIF
IF keyword_set(totcenter) THEN $
oplot,[cen164[0]],[cen164[1]],psym=2

plot_map,tm236,title='Nancay map 236 MHz',/contour,/percent, $
         levels=[10,20,30,40,50,60,70,80,90],/limb,lmcolor=0, $
         xrange=[-1024,1024],yrange=[-1024,1024],_extra=_extra

IF exist(cent) THEN BEGIN
oplot,[cent[1,*,0]],[cent[1,*,1]],psym=1
ENDIF
IF keyword_set(totcenter) THEN $
oplot,[cen236[0]],[cen236[1]],psym=2

plot_map,tm327,title='Nancay map 327 MHz',/contour,/percent, $
         levels=[10,20,30,40,50,60,70,80,90],/limb,lmcolor=0, $
         xrange=[-1024,1024],yrange=[-1024,1024],_extra=_extra


IF exist(cent) THEN BEGIN
oplot,[cent[2,*,0]],[cent[2,*,1]],psym=1
ENDIF
IF keyword_set(totcenter) THEN $
oplot,[cen327[0]],[cen327[1]],psym=2

plot_map,tm410,title='Nancay map 410 MHz',/contour,/percent, $
         levels=[10,20,30,40,50,60,70,80,90],/limb,lmcolor=0, $
         xrange=[-1024,1024],yrange=[-1024,1024],_extra=_extra

IF exist(cent) THEN BEGIN
oplot,[cent[3,*,0]],[cent[3,*,1]],psym=1
ENDIF
IF keyword_set(totcenter) THEN $
oplot,[cen410[0]],[cen410[1]],psym=2

plot_map,tm432,title='Nancay map 432 MHz',/contour,/percent, $
         levels=[10,20,30,40,50,60,70,80,90],/limb,lmcolor=0, $
         xrange=[-1024,1024],yrange=[-1024,1024],_extra=_extra

IF exist(cent) THEN BEGIN
oplot,[cent[4,*,0]],[cent[4,*,1]],psym=1
ENDIF
IF keyword_set(totcenter) THEN $
oplot,[cen432[0]],[cen432[1]],psym=1

plot,[0],[0],xstyle=4,ystyle=4 


xyouts,0.1,0.9,anytim((*ptr164[0]).time,/yohkoh,/date)+' '+anytim((*ptr164[0]).time,/yohkoh,/time)+' - '+anytim((*ptr164[n_elements(ptr164)-1]).time,/yohkoh,/time)

xyouts,0.1,0.7,'Center at 164 MHz: ('+ $
       strtrim(string(cen164[0],format='(f10.1)'),2)+'" , '+ $
       strtrim(string(cen164[1],format='(f10.1)'),2)+'")'
xyouts,0.1,0.5,'Center at 236 MHz: ('+ $
       strtrim(string(cen236[0],format='(f10.1)'),2)+'" , '+ $
       strtrim(string(cen236[1],format='(f10.1)'),2)+'")'
xyouts,0.1,0.3,'Center at 327 MHz: ('+ $
       strtrim(string(cen327[0],format='(f10.1)'),2)+'" , '+ $
       strtrim(string(cen327[1],format='(f10.1)'),2)+'")'
xyouts,0.1,0.1,'Center at 410 MHz: ('+ $
       strtrim(string(cen410[0],format='(f10.1)'),2)+'" , '+ $
       strtrim(string(cen410[1],format='(f10.1)'),2)+'")'
xyouts,0.1,-0.1,'Center at 432 MHz: ('+ $
       strtrim(string(cen432[0],format='(f10.1)'),2)+'" , '+ $
       strtrim(string(cen432[1],format='(f10.1)'),2)+'")'

device,/close
set_plot,'x'

!P=oldp

END


