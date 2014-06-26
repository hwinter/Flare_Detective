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
;      
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;
;-

;{pos:qpos,tpos:tpos,framelist:framelist,n_sources:N,n_setframes:M}

FUNCTION pg_transform_pos,pos_st,xrange=xrange,yrange=yrange $
                         ,usetrendline=usetrendline

pst=pos_st;local copy of pos_st to be modified

flist=pst.framelist
pos=pst.pos
tpos=pst.tpos

M=pst.n_setframes
N=pst.n_sources

ntotim=total(flist[1,*]-flist[0,*]+1)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;transform input into array of x and y values + nan indices
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


posxarr=ptrarr(N)
posyarr=ptrarr(N)

arrnan=ptrarr(N)

;un-pointerization of positional data, keeping NANs, THEN
;un-NAN-ization of the data, keeping track of the indices of the NANs
FOR i=0,N-1 DO BEGIN
   xpos=0.
   ypos=0.
   time=[0.,0.]
   FOR j=0,M-1 DO BEGIN
      xpos=[xpos,reform((*pst.pos[i,j])[0,*])]
      ypos=[ypos,reform((*pst.pos[i,j])[1,*])]
      time=[[time],[(*pst.tpos[i,j])]]
   ENDFOR
   xpos=xpos[1:ntotim]
   ypos=ypos[1:ntotim]
   time=time[*,1:ntotim]

   nanind=where(finite(xpos))
   
   posxarr[i]=ptr_new([xpos])
   posyarr[i]=ptr_new([ypos])
   arrnan[i]=ptr_new(nanind)

ENDFOR

pst=add_tag(pst,posxarr,'POSXARR')
pst=add_tag(pst,posyarr,'POSYARR')
pst=add_tag(pst,time,'TIME')
pst=add_tag(pst,arrnan,'NANIND')


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;fit trend line and project position on the trend line
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


IF NOT keyword_set(usetrendline) THEN BEGIN 

   h=dblarr(N)  ;intercept of the best fit line to the positions
   m=dblarr(N)  ;slope     of the best fit line to the positions

   FOR i=0,N-1 DO BEGIN
      x=(*pst.posxarr[i])[*pst.nanind[i]]
      y=(*pst.posyarr[i])[*pst.nanind[i]]


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


parallp=ptrarr(N)
perpp=ptrarr(N)

xline=[0.,10.]

FOR i=0,N-1 DO BEGIN 

   yline=m[i]*xline+h[i]

   posxok=(*pst.posxarr[i])[*pst.nanind[i]]
   posyok=(*pst.posyarr[i])[*pst.nanind[i]]

   ;define new normalized vector la 

   la_=[xline[1]-xline[0],yline[1]-yline[0]]
   la=la_/sqrt(la_[0]^2+la_[1]^2)

   p=[xline[0],yline[0]]

   ;scalar product
   ;get parallel and perpendicular component

   ;stop

   parallp[i]=ptr_new((posxok-p[0])*la[0] +(posyok-p[1])*la[1])

   ;stop
   
   signum=2*((posyok GE m[i]*posxok+h[i])-0.5)
   perpp[i]=ptr_new(signum*sqrt((posxok-p[0])^2 +(posyok-p[1])^2 $
                                -(*parallp[i])^2))

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
