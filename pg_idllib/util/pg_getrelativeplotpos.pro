;+
; NAME:
;
;   pg_getrelativeplotpos
;
; PURPOSE:
;
;   returns the position of a plot in normalized coordinates, given a relative
;   position and two plot coordinates i,j out of n row and m columns
;
; CATEGORY:
;
;   plot util
;
; CALLING SEQUENCE:
;
;
;
; INPUTS:
;
;
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
;-

;.comp  pg_getrelativeplotpos

; PRO pg_getrelativeplotpos_test

;   FOR i=0,4 DO BEGIN 
;      FOR j=0,3 DO BEGIN 

;         pos=pg_getrelativeplotpos([0.25,0.2,0.9,0.7],i=i,j=j,n=5,m=4)

;         plot,[1,2,1],position=pos,/noerase,color=5

;      ENDFOR
;   ENDFOR


; END


FUNCTION pg_getrelativeplotpos,relpos,i=i,j=j,n=n,m=m,dxr=dxr,dxl=dxl,dyb=dyb,dyu=dyu

  relpos=fcheck(relpos,[0.,0,1,1])

  i=fcheck(i,0)
  j=fcheck(j,0)
  
  n=fcheck(n,2)
  m=fcheck(m,2)

  dxl=fcheck(dxl,0.05)
  dxr=fcheck(dxr,dxl)

  dyb=fcheck(dyb,0.05)
  dyu=fcheck(dyu,dyb)

  dxpos=1./n
  dypos=1./m
  
  outposition=[i*dxpos,(m-j-1)*dypos,(i+1)*dxpos,(m-j)*dypos]
  outposition=outposition+[dxl,dyb,-dxr,-dyu]

  doutxpos=outposition[2]-outposition[0]
  doutypos=outposition[3]-outposition[1]
  drelxpos=relpos[2]-relpos[0]
  drelypos=relpos[3]-relpos[1]

  finalposition=[outposition[0]+relpos[0]*doutxpos, $
                 outposition[1]+relpos[1]*doutypos, $
                 outposition[0]+relpos[0]*doutxpos+drelxpos*doutxpos,$
                 outposition[1]+relpos[1]*doutypos+drelypos*doutypos]


  RETURN,finalposition

END



