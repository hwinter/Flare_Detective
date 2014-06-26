;+
; NAME:
;      pg_add_velocity
;
; PURPOSE: 
;      add (compute) velocity information to a position data structure
;
; CALLING SEQUENCE:
;
;      res=pg_add_velocity(pos_st,...)
;
; INPUTS:
;      
;      pos_st: (transformed) position structure
;
;  
; OUTPUTS:
;      
;      
; KEYWORDS:
;      
;
; HISTORY:
;
;      14-DEC-2004 written
;      
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;
;-



FUNCTION pg_add_velocity,pos_st

pst=pos_st

ns=pst.n_sources

;conversion factor 1 image unit (arcsec) <-> spatial unit (cm)
as2cm=72500000.d

;frame times
t=0.5*(pst.frametimes[0,*]+pst.frametimes[1,*])

xv=ptrarr(ns)
yv=ptrarr(ns)
tv=ptrarr(ns)

FOR j=0,ns-1 DO BEGIN

   x=pst.posxarr[j,*]
   y=pst.posyarr[j,*]

   indx=where(finite(x),countx)
   indy=where(finite(y),county)

   IF (countx-county) NE 0 OR (countx+county LT 4) THEN RETURN,-1

   vx=dblarr(countx-1)
   vy=dblarr(county-1)
   vt=dblarr(countx-1)

   ;next loop could be done with x[shift(indx,1)] or something like that
   FOR i=0,countx-2 DO BEGIN
      vx[i]=as2cm*(x[indx[i+1]]-x[indx[i]])/(t[indx[i+1]]-t[indx[i]])
      vy[i]=as2cm*(y[indx[i+1]]-y[indx[i]])/(t[indx[i+1]]-t[indx[i]])
      vt[i]=0.5*(t[indx[i+1]]+t[indx[i]])
   ENDFOR

   xv[j]=ptr_new(vx)
   yv[j]=ptr_new(vy)
   tv[j]=ptr_new(vt)

ENDFOR

pst=add_tag(pst,xv,'X_VELOCITY')
pst=add_tag(pst,yv,'Y_VELOCITY')
pst=add_tag(pst,tv,'T_VELOCITY')

vpar=ptrarr(ns)
vperp=ptrarr(ns)

FOR i=0,ns-1 DO BEGIN
   y=pst.tlin_slope[i]
   x=1.

   pg_vect_proj,x=*pst.x_velocity[i],y=*pst.y_velocity[i]$
               ,lx=x,ly=y,par=thisvpar,perp=thisvperp,/signum

   vpar[i]=ptr_new(thisvpar)
   vperp[i]=ptr_new(thisvperp)

ENDFOR

pst=add_tag(pst,vpar,'PAR_VELOCITY')
pst=add_tag(pst,vperp,'PERP_VELOCITY')


RETURN,pst

END
