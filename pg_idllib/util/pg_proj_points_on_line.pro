;+
; NAME:
;
; pg_proj_points_on_line
;
; PURPOSE:
;
; projects a series of points in the plane given by their coordinates
; x,y alog a given line, that is give the perpendicular distance from
; each point to the line, and the parallel distance from a point lying
; on the straight line
;
;
; CATEGORY:
;
; geometry utils
;
; CALLING SEQUENCE:
;
; pg_proj_points_on_line,x,y,slope=slope,intercept=intercept,lx=lx,ly=ly
;    ,lpoint=lpoint,parallel=parallel,perpend=perpend
;
; INPUTS:
;
; x,y: coordinates of the points (arrays allowed)
; lpoint: a reference point on the line, see below
;
; slope,intercept: parametrization of the line, in this case lpoint
;    need to be just an x value, 0 is taken if none is given
; lx,ly: alternative parametrization of the line as a directional
;    vector (need not to be of length one), in this case lpoint needs
;    to be an x,y array, if none is given, 0,0 is used.        
;
;
; 
; OPTIONAL INPUTS:
;
; 
; KEYWORD PARAMETERS:
;
;
; OUTPUT:
;
; parallel,perpendicular: projected coordinates
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
; 19-JAN-2005 written & basic testing P.G.
; 20-JAN-2005 x and y works ok even with NANs in input
;
;-
PRO pg_proj_points_on_line_test
nan=!values.f_nan
x=[1.,2]
y=[1.,1]

errx=[0.25,0.2]
erry=[0.5,0.3]

!p.color=0
!p.background=255

wdef,1,512,512
plot,x,y,psym=3,xrange=[-1,3],yrange=[-1,3],/isotropic

FOR i=0,n_elements(x)-1 DO BEGIN
   oplot,x[i]+errx[i]*[-1,1],y[i]*[1,1],thick=2
   oplot,x[i]*[1,1],y[i]+erry[i]*[-1,1],thick=2
ENDFOR


slope=0.
inter=0.

pg_proj_points_on_line,x,y,slope=slope,intercept=inter,parallel=par,perpend=per,err1=errx,err2=erry,tiltangle=[!Pi/3,!Pi/2],errpar=errpar,errper=errper




print,par,per
print,errpar,errper

oplot,!x.crange,slope*!x.crange+inter

FOR i=0,n_elements(x)-1 DO BEGIN
   oplot,x[i]+errpar[i]*[-1,1],y[i]*[1,1],color=3
   oplot,x[i]*[1,1],y[i]+errper[i]*[-1,1],color=3
ENDFOR


; FOR i=0,n_elements(par)-1 DO BEGIN
;    oplot,par[i]*[1,1]/sqrt(2),0.2+par[i]*[1,1]/sqrt(2),psym=4
; ENDFOR



END

PRO pg_proj_points_on_line,x,y,slope=slope,intercept=intercept,lx=lx,ly=ly $
        ,lpoint=lpoint,parallel=parallel,perpend=perpend $
        ,err1=err1,err2=err2,tiltangle=tiltangle,errpar=errpar,errper=errper


IF NOT(exist(x)) OR NOT(exist(y)) THEN BEGIN 
   print,'Please input x and y!'
   RETURN
ENDIF

;check for NaN's


n=n_elements(x)
nn=n_elements(y)

IF nn LT n THEN BEGIN
   y=[y,replicate(!values.f_nan,n-nn)]
ENDIF


ind=where(finite(x) + finite(y) EQ 2,count)

IF count EQ 0 THEN BEGIN
   parallel=replicate(!values.f_nan,n)
   perpend=replicate(!values.f_nan,n)
   RETURN
ENDIF


xx=x[ind]
yy=y[ind]

n=n_elements(x)

parallel=replicate(!values.d_nan,n)
perpend=replicate(!values.d_nan,n)

IF exist(slope) THEN BEGIN
   IF NOT exist(intercept) THEN BEGIN 
      print,'Please input a slope and an intercept!'
   RETURN
   ENDIF

   IF NOT exist(lpoint) THEN lp=[0,intercept] ELSE $
      lp=[lpoint[0],lpoint[0]*slope+intercept]

   dv=[1,slope];directional vector
   dv=dv/sqrt(1+slope*slope)

ENDIF ELSE BEGIN
   IF (NOT exist(lx)) OR (NOT exist(ly)) THEN BEGIN
      print,'Please input lx, ly or slope,intercept'
      return
   ENDIF

   IF n_elements(lpoint) LT 2 THEN lp=[0,0] ELSE lp=lpoint[0:1]
   
   dv=[lx,ly]/sqrt(lx*lx+ly*ly)

ENDELSE 

;now I got a point on the line lp and a directional vector dv of
;length 1

dx=xx-lp[0]
dy=yy-lp[1]

d=sqrt(dx*dx+dy*dy)

okdind=where(d GT 0.,count)
cosalpha=replicate(0d ,n)

IF count GT 0 THEN $
  cosalpha[okdind]=(dv[0]*dx[okdind]+dv[1]*dy[okdind])/d[okdind]


parallel[ind]=d*cosalpha
perpend[ind]=d*sqrt(1-cosalpha*cosalpha)

signum=-((abs(xx-(lp[0]+parallel[ind]*dv[0]-perpend[ind]*dv[1])) GT abs(xx-(lp[0]+parallel[ind]*dv[0]+perpend[ind]*dv[1])))-0.5)*2.

perpend[ind]=signum*perpend[ind]


;error transformation....


IF exist(err1) AND exist(err2) THEN BEGIN 

;get angle of line...
  angle=atan(dv[1],dv[0])
  IF angle LT 0 THEN angle=!dPi*2+angle

  IF NOT exist(tiltangle) THEN errangle=replicate(0.,n) ELSE errangle=tiltangle

  inda=where(errangle LT 0, count)
  IF count GT 0 THEN errangle[inda]=!Pi*2+errangle[inda]

  indb=where(errangle GT angle,count)
  dangle=angle-errangle
  IF count GT 0 THEN BEGIN
     dangle[indb]=(2*!dPi-errangle[indb])+angle
  ENDIF

  errpar=reform(sqrt(err1^2*cos(dangle)^2+err2^2*sin(dangle)^2))
  errper=reform(sqrt(err1^2*sin(dangle)^2+err2^2*cos(dangle)^2))



  ;calculate error the ok way!

ENDIF






END
