;+
; NAME:
;
;   pg_dashedlineoplot
;
; PURPOSE:
;
;   overplot a (straight) dashed line with some more control than IDL defaults
;
; CATEGORY:
;
;   plot util
;
; CALLING SEQUENCE:
;
;  pg_dashedlineoplot,p1,p2,dashlen=dashlen,spacelen=spacelen,phase=phase
;                    ,dashcolor=dashcolor,spacecolor=spacecolor, [plus
;                    all keyword accepeted by oplot (linestyle is ignored)]
;
; INPUTS:
;
;  p1: [x,y] of starting point
;  p2: [x,y] of ending point
;  dashlen: length of the dashes (in fraction of total length)
;  spacelen: length of white space between dashes (in fraction of total length)
;  phase: number between 0 and 1, represent the fraction of (dashlen+spacelen)
;         that is used as the starting point
;  dashcolor: color of the dash (default !p.color)
;  spacecolor: color of the space (default !p.background)
;  dashthick: thickness of the dash (default !p.thick)
;  spacethick: thickness of the space (default !p.thick)
;
; OPTIONAL INPUTS:
;
;
;
; KEYWORD PARAMETERS:
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
;  p1=[1,1] & p2=[5,3]
;  plot,[0,0],xrange=[0,10],yrange=[0,7],/iso
;  pg_dashedlineoplot,p1,p2,dashlen=0.05,spacelen=0.01,phase=0.0
;
; AUTHOR:
;
;   Paolo Grigis (pgrigis@astro.phys.ethz.ch)
;
;   11-JUL-2007 written
;   23-MAR-2009 removed SSW dependencies
;
;-

;.comp pg_dashedlineoplot


PRO pg_dashedlineoplot_test

plot,[0,0],[1,1],/nodata,/isotropic

p1=[0.3,0.2]
p2=[0.7,0.8]


linecolors;from SSW IDL

pg_dashedlineoplot,p1,p2,dashlen=0.02,spacelen=0.02,phase=0. $
                  ,dashcolor=2,spacecolor=5,thick=2,dashthick=8

plots,[p1[0],p2[0]],[p1[1],p2[1]],psym=6


plot,[0,0],[1,1],/nodata,/isotropic
pg_dashedlineoplot,p1,p2,dashlen=0.25,spacelen=0.25,phase=0. $
                  ,dashcolor=2,spacecolor=5,thick=2,dashthick=8

plots,[p1[0],p2[0]],[p1[1],p2[1]],psym=6

END


PRO pg_dashedlineoplot,p1,p2,dashlen=dashlen,spacelen=spacelen,phase=phase $
                      ,dashcolor=dashcolor,spacecolor=spacecolor,color=color $
                      ,linestyle=linestyle,thick=thick,dashthick=dashthick $
                      ,spacethick=spacethick $
                      ,_extra=_extra 


  ;default values: dash settings
  dashlen=fcheck(dashlen,0.05)
  spacelen=fcheck(spacelen,0.05)
  phase=fcheck(phase,0.)

  ;default values: dash colors
  color=fcheck(color,!p.color)
  dashcolor=fcheck(dashcolor,color)
  spacecolor=fcheck(spacecolor,!P.background)

  ;default values: dash thickness
  thick=fcheck(thick,!p.thick)
  dashthick=fcheck(dashthick,thick)
  spacethick=fcheck(spacethick,thick)


  ;computes dash length in data space
  dx=p2[0]-p1[0]
  dy=p2[1]-p1[1]
  d=sqrt(dx*dx+dy*dy)
  len=dashlen+spacelen

  ddashx=dx*dashlen
  ddashy=dy*dashlen
  dspacex=dx*spacelen
  dspacey=dy*spacelen
  dstepx=dx*len
  dstepy=dy*len
  phx=-dx*len*phase
  phy=-dy*len*phase

  nsteps=ceil(1/len)


  minx=min([p1[0],p2[0]])
  miny=min([p1[1],p2[1]])
  maxx=max([p1[0],p2[0]])
  maxy=max([p1[1],p2[1]])


  ;plots the dashes one by one (yes, slow)
  FOR i=0,nsteps-1 DO BEGIN 

     xdash=p1[0]+dstepx*i+[0,ddashx]+phx >minx <maxx
     ydash=p1[1]+dstepy*i+[0,ddashy]+phy >miny <maxy

     xspace=p1[0]+dstepx*i+ddashx+[0,dspacex]+phx >minx <maxx
     yspace=p1[1]+dstepy*i+ddashy+[0,dspacey]+phy >miny <maxy

     oplot,xdash,ydash,color=dashcolor,thick=dashthick,_extra=_extra
     oplot,xspace,yspace,color=spacecolor,thick=spacethick,_extra=_extra

  ENDFOR


END
