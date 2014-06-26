;+
; NAME:
;
;   pg_dashedcurveoplot
;
; PURPOSE:
;
;   overplot a dashed (possibly curved) line with some more control than
;   IDL defaults
;   !!!!!!!!!!!!!!!!!!!!!!!!!! NOT working yet !!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;
; CATEGORY:
;
;   plot util
;
; CALLING SEQUENCE:
;
;  pg_dashedcurveoplot,x,y,dashlen=dashlen,spacelen=spacelen,phase=phase
;                    ,dashcolor=dashcolor,spacecolor=spacecolor, [plus
;                    all keyword accepeted by oplot (linestyle is ignored)]
;
; INPUTS:
;
;  x,y: coordinates of the point on the plot
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
;
;
; AUTHOR:
;
;   Paolo Grigis (pgrigis@astro.phys.ethz.ch)
;
;   written 28-NOV-2007
;
;-

;.comp pg_dashedcurveoplot

PRO pg_dashedcurveoplot_test

t=findgen(10)/9*2*!Pi

x=sin(t)
y=cos(t)

plot,x,y,/iso,psym=6

pg_dashedcurveoplot,x,y,dashcolor=2,spacecolor=10,phase=0

END

PRO pg_dashedcurveoplot,x,y,dashlen=dashlen,spacelen=spacelen,phase=phase $
                      ,dashcolor=dashcolor,spacecolor=spacecolor,color=color $
                      ,linestyle=linestyle,thick=thick,dashthick=dashthick $
                      ,spacethick=spacethick $
                      ,_extra=_extra 


  dashlen=fcheck(dashlen,0.05)
  spacelen=fcheck(spacelen,0.05)
  phase=fcheck(phase,0.)

  color=fcheck(color,!p.color)

  dashcolor=fcheck(dashcolor,color)
  spacecolor=fcheck(spacecolor,!P.background)

  thick=fcheck(thick,!p.thick)

  dashthick=fcheck(dashthick,thick)
  spacethick=fcheck(spacethick,thick)


  ;compute partial lengths

  n=n_elements(x)
  l=(shift(x,-1)-x)^2+(shift(y,-1)-y)^2
  l=l[0:n-2]
  ltot=total(l)

  ;renormalize legths
  thisdashlen=dashlen*ltot/l
  thisspacelen=spacelen*ltot/l
  
  thisphase=phase

  FOR i=0,n-2 DO BEGIN

 
     pg_dashedlineoplot,[x[i],y[i]],[[x[i+1]],[y[i+1]]],dashlen=thisdashlen[i],spacelen=thisspacelen[i] $
                        ,phase=thisphase $
                        ,dashcolor=dashcolor,spacecolor=spacecolor,color=color $
                        ,linestyle=linestyle,thick=thick,dashthick=dashthick $
                        ,spacethick=spacethick $
                        ,_extra=_extra 


     IF i LT n-2 THEN BEGIN 
        dphase=((l[i]/(thisdashlen[i]+thisspacelen[i])) MOD 1)*(thisdashlen[i]+thisspacelen[i]) $
                /l[i+1]
        thisphase=thisphase+dphase
     ENDIF

 

  ENDFOR

 
END
