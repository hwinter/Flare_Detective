;+
; NAME:
;      pg_posbox_fit
;
; PURPOSE: 
;      fit image source position, given input boxes for different sources
;
; CALLING SEQUENCE:
;
;      pos=pg_posbox_fit,ptr,framelist,pbox
;
; INPUTS:
;      
;      ptr:  pointer to an array of maps
;      framelist: array [2,M]. This is the set of frames corresponding
;      to each disconnected fitting  
;      pbox: pointer to an array [N,M] of boxes, N sources for M set
;      of frames
;  
; OUTPUTS:
;      
;      
; KEYWORDS:
;      quiet: suppress info messages  
;
; HISTORY:
;
;      15-NOV-2004 written PG
;      
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;
;-

FUNCTION pg_posbox_fit,ptr,framelist,pbox,fitmethod=fitmethod

IF NOT exist(ptr) THEN BEGIN
   print,'Invalid input'
   RETURN,-1
ENDIF

fitmethod=fcheck(fitmethod,'GAUSSFIT')

M=n_elements(framelist[0,*])
N=n_elements(pbox[*,0])

qpos=ptrarr(N,M)
tpos=ptrarr(N,M)

FOR i=0,N-1 DO BEGIN
   FOR j=0,M-1 DO BEGIN 

      print,'Now doing source '+strtrim(string(i),2)+' and frame set ' $
         +strtrim(string(j))

      nframes=framelist[1,j]-framelist[0,j]+1
      pos=fltarr(2,nframes)
      time=dblarr(2,nframes)

      FOR k=0,nframes-1 DO BEGIN

         map=*ptr[framelist[0,j]+k]
         IF tag_exist(map,'PG_TIME_RANGE') THEN time[*,k]=map.pg_time_range

         IF finite((*pbox[i,j])[0]) THEN BEGIN 
            pg_mapcfit,map,x,y,roi=*pbox[i,j],method=fitmethod,/rdata 
            pos[*,k]=[x,y]
         ENDIF ELSE pos[*,k]=!values.f_nan*[1,1]
         
      ENDFOR 

      qpos[i,j]=ptr_new(pos)
      tpos[i,j]=ptr_new(time)
      print,' '

   ENDFOR
ENDFOR


return,{pos:qpos,tpos:tpos,framelist:framelist,pbox:pbox $
       ,n_sources:N,n_setframes:M}

END
