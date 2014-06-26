;+
; NAME:
;      pg_transform_pos
;
; PURPOSE: 
;      look at the position informations and add more information
;      in the structure with more elaborated data in it. (projection
;      along the trend line etc., detailed times etc.)
;
; CALLING SEQUENCE:
;
;      new_pos_st=pg_transform_pos(pos_st)
;
; INPUTS:
;      
;      pos_st: position structure, the output from pg_posbox_fit
;
;      framelist: array [2,M]. This is the set of frames corresponding
;                 to each disconnected fitting series 
;      (x,y)range: if set, just keep positions inside that range for
;                  straight line fitting
;
;       usetrendline: use trend line in the structure, nstead of
;       updating it to use instead of fitting that
;                     to the data, useful for comparison of different dataset
;                     (not implemented yet)
;  
; OUTPUTS:
;      
;      
; KEYWORDS:
;      
;
; HISTORY:
;
;      15-NOV-2004 written PG
;      13-DEC-2004 changed to accoubt for the new pos_st format
;      14-DEC-2004 corrected perpendicular position too
;      
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;
;-

;{pos:qpos,tpos:tpos,framelist:framelist,n_sources:N,n_setframes:M}

FUNCTION pg_transform_pos2,pos_st,xrange=xrange,yrange=yrange $
                         ,usetrendline=usetrendline

pst=pos_st;local copy of pos_st to be modified


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;transform input into array of x and y values + nan indices
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;define source array list... 

Nframes=pst.n_setframes
Ntotframes=pst.n_totframes
Nsources=pst.n_sources
N=Nsources

;output position array init
xpos=dblarr(Ntotframes,Nsources)
ypos=dblarr(Ntotframes,Nsources)

;set invalid pos as default
xpos[*]=!Values.F_NAN
ypos[*]=!Values.F_NAN
   
FOR i=0,nframes-1 DO BEGIN 
   FOR j=0,nsources-1 DO BEGIN 

      actualframes=*(pst.framelist[j,i])
      pos=*((pst.pos)[j,i])

      FOR l=0,n_elements(actualframes)-1 DO BEGIN
         xpos[actualframes[l],j]=pos[0,l]
         ypos[actualframes[l],j]=pos[1,l]         
      ENDFOR

   ENDFOR
ENDFOR

pst=add_tag(pst,transpose(xpos),'POSXARR')
pst=add_tag(pst,transpose(ypos),'POSYARR')


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;fit trend line and project position on the trend line
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


IF NOT keyword_set(usetrendline) THEN BEGIN 

   h=dblarr(N)  ;intercept of the best fit line to the positions
   m=dblarr(N)  ;slope     of the best fit line to the positions

   FOR i=0,N-1 DO BEGIN

      x=pst.posxarr[i,*]
      y=pst.posyarr[i,*]
      xind=where(finite(x),xcount)
      yind=where(finite(y),ycount)

      IF (xcount EQ 0) OR  (ycount EQ 0) THEN BEGIN
         print,'Error: invalid x or y positions'
         stop
         RETURN,-1
      ENDIF

      x=x[xind]
      y=y[yind]

      IF exist(xrange) AND exist(yrange) THEN BEGIN 

         ind=where((x GT xrange[0] AND x LT xrange[1]) AND $
                   (y GT yrange[0] AND y LT yrange[1]))
 
         x=x[ind]
         y=y[ind]

      ENDIF

      ;decide whether to take an x vs. y fitting or the other way round
      ;check the spread of the data: if the data is more spread in x than in y
      ;then make an LS(y|x) fitting, otherwise and LS(x|y) fit

      dx=max(x)-min(x)
      dy=max(y)-min(y)

      sixlin,x,y,a,da,b,db

      IF dx GE dy THEN lsind=0 ELSE lsind=1

      h[i]=a[lsind]
      m[i]=b[lsind]

   ENDFOR

   ;got intercept and slopes

   pst=add_tag(pst,h,'TLIN_INTERCEPT')
   pst=add_tag(pst,m,'TLIN_SLOPE')

ENDIF $
ELSE BEGIN
   m=pst.tlin_slope
   h=pst.tlin_intercept
ENDELSE


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;projection comes now:


parallp=dblarr(N,ntotframes)
perpp=dblarr(N,ntotframes)

xline=[0.,10.]

FOR i=0,N-1 DO BEGIN 

   yline=m[i]*xline+h[i]

   x=pst.posxarr[i,*]
   y=pst.posyarr[i,*]
;   xind=where(finite(x),xcount)
;   yind=where(finite(y),ycount)
   posxok=x;[xind]
   posyok=y;[yind]

   ;define new normalized vector la 

   la_=[xline[1]-xline[0],yline[1]-yline[0]]
   la=la_/sqrt(la_[0]^2+la_[1]^2)

   p=[xline[0],yline[0]]

   ;scalar product
   ;get parallel and perpendicular component

   ;stop

   parallp[i,*]=(posxok-p[0])*la[0] +(posyok-p[1])*la[1]

   ;stop
   
   signum=2*((posyok GE m[i]*posxok+h[i])-0.5)
   perpp[i,*]=signum*sqrt((posxok-p[0])^2 +(posyok-p[1])^2 -(parallp[i,*])^2)

; the following line returns the absolute value of the perp distance
; but what about the sign? see above
;   perpp[i]=ptr_new(sqrt((posxok-p[0])^2 +(posyok-p[1])^2 -(*parallp[i])^2))


ENDFOR

pst=add_tag(pst,parallp,'PARALLP')
pst=add_tag(pst,perpp,'PERPP')


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

return,pst

END
