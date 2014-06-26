;+
; NAME:
;      pg_plot_posboxes
;
; PURPOSE: 
;      plots the maps with posboxes (optionally positions)
;
; CALLING SEQUENCE:
;
;      pg_plot_posboxes,ptr,pbox,...
;
; INPUTS:
;      
;      ptr: array of pointer to maps
;      pos: the fitted positions
;
; OUTPUTS:
;      
;      
; KEYWORDS:
;      
;
; HISTORY:
;
;      17-NOV-2004 written PG
;      
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;
;-


PRO pg_plot_posboxes,ptr,pos,psym=psym,pthick=pthick,_extra=_extra

flist=pos.framelist
pbox=pos.pbox

;nim=total(flist[1,*]-flist[0,*])+1

N=n_elements(pbox[*,0])
M=n_elements(flist[0,*])

psym=fcheck(psym,1)
pthick=fcheck(pthick,1)

FOR i=0,M-1 DO BEGIN
   FOR j=flist[0,i],flist[1,i] DO BEGIN 

      j0=flist[0,i]
      map=*ptr[j]

      title='PEAK Nr. '+strtrim(string(i),2)+' , FRAME '+strtrim(string(j),2) $
         +' ID: '+map.pg_id

      plot_map,map,title=title,_extra=_extra

      
      FOR k=0,N-1 DO BEGIN
         box=*pbox[k,i]
         oplot,box[[0,1,1,0,0]],box[[2,2,3,3,2]]
         posarr=*pos.pos[k,i]
         
         oplot,posarr[[0,0],j-j0],posarr[[1,1],j-j0],psym=psym,thick=pthick

      ENDFOR


   ENDFOR
ENDFOR



END
