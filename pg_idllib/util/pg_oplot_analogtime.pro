;+
; NAME:
;
; pg_oplot_analogtime
;
; PURPOSE:
;
; overplot an analog clok showing the input time
;
; CATEGORY:
;
; plot+time utilities
;
; CALLING SEQUENCE:
;
; pg_oplot_analogtime,time,size,position [,/data]
;
; INPUTS:
;
; time: in anytim compatible format
; position: x,y coordinates of clock center, in normalized coordinates
;           (or data coordinates if /data is set)
; size: clock size in normalized coordinates (even if /data is set!) 
;
; OPTIONAL INPUTS:
;
;
; KEYWORD PARAMETERS:
;
; hour/min-thick: thickness of hour/min hand
; color: clock color
; OUTPUT:
;
; NONE
;
; OPTIONAL OUTPUTS:
;
;
; CALLS:
;
; anytim
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
; a plot MUST already be present
;
; PROCEDURE:
;
; if /data is set, convert to normalized coordinates, checking if the
; axis type is linear or logarithmic
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
; 15-JUL-2004 WRITTEN
;
;-
;plot,[1,4,2,3]
;time='15-JUL-2004 09:22:32'
;size=0.1
;position=[2.,3]
;pg_oplot_analogtime,time,size,position,/data

PRO pg_oplot_analogtime,time,size,position,data=data,color=color $
                       ,hourthick=hourthick,minthick=minthick $
                       ,secthick=secthick

Ncirclepoints=128;number of points for drawing the circle 

maintickl=0.125;length of 0,3,6,9,12 ticks, in units of size
secondarytickl=0.5*maintickl;length of other hours, in units of size

hourlen=0.5
minlen=0.85
seclen=0.95

minthick=fcheck(minthick,1)
hourthick=fcheck(hourthick,2*minthick)
secthick=fcheck(secthick,0)

circlex=fltarr(Ncirclepoints)
circley=fltarr(Ncirclepoints)
omega=findgen(Ncirclepoints)/(Ncirclepoints-1)*2*!PI

IF NOT exist(time) THEN BEGIN
   print,'Please input a time in anytim compatible format!'
   RETURN
ENDIF

t=anytim(time[0],/external)
sec=float(t[2])
min=float(t[1])+sec/60.
hour=float(t[0] MOD 12)+min/60.


IF keyword_set(data) THEN BEGIN

   xscaling=!X.S
   yscaling=!Y.S

   IF !X.type EQ 1 THEN $
     xnorm=alog10(position[0])*xscaling[1]+xscaling[0] $
   ELSE $
     xnorm=position[0]*xscaling[1]+xscaling[0]

   IF !Y.type EQ 1 THEN $
     ynorm=alog10(position[1])*yscaling[1]+yscaling[0] $
   ELSE $
     ynorm=position[1]*yscaling[1]+yscaling[0]

ENDIF $
ELSE BEGIN 
   xnorm=position[0]
   ynorm=position[1]
ENDELSE

axisratio=double(!D.x_size)/!D.y_size

circlex=xnorm+0.5*size*cos(omega)
circley=ynorm+axisratio*0.5*size*sin(omega)


plots,circlex,circley,/normal,color=color


FOR i=0,11 DO BEGIN
   IF (i MOD 3) EQ 0 THEN tlen=maintickl ELSE tlen=secondarytickl
   angle=2*!Pi/12.*i
   x=xnorm+size*cos(angle)*[0.5,0.5-tlen]
   y=ynorm+axisratio*size*sin(angle)*[0.5,0.5-tlen]
   plots,x,y,/normal,color=color
ENDFOR 

hourangle=!Pi*0.5-2*!Pi/12.*hour
minangle =!Pi*0.5-2*!Pi/60.*min

plots,xnorm+size*cos(hourangle)*0.5*[0.,hourlen] $
     ,ynorm+axisratio*size*sin(hourangle)*0.5*[0,hourlen] $
     ,thick=hourthick,/normal,color=color

plots,xnorm+size*cos(minangle)*0.5*[0.,minlen] $
     ,ynorm+axisratio*size*sin(minangle)*0.5*[0,minlen] $
     ,thick=minthick,/normal,color=color

IF secthick GT 0 THEN BEGIN

secangle =!Pi*0.5-2*!Pi/60.*sec

plots,xnorm+size*cos(secangle)*0.5*[0.,seclen] $
     ,ynorm+axisratio*size*sin(secangle)*0.5*[0,seclen] $
     ,thick=secthick,/normal,color=color

ENDIF

;ptim,time
;print,hour,min,sec

; arrow,xnorm,ynorm,xnorm+size*cos(hourangle)*0.5*hourlen $
;      ,ynorm+axisratio*size*sin(hourangle)*0.5*hourlen $
;      ,thick=2,/normal,/solid,hsize=-0.3

; arrow,xnorm,ynorm,xnorm+size*cos(minangle)*0.5*minlen $
;      ,ynorm+axisratio*size*sin(minangle)*0.5*minlen $
;      ,thick=1,/normal,/solid,hsize=-0.15


END
